# app/services/weather_fetcher.rb
# Responsible for:
# - geocoding the input
# - caching results per normalized location (zip or normalized address)
# - fetching current weather from OpenWeatherMap (or other provider)
# - returning a stable hash that controller can render
class WeatherFetcher
  CACHE_TTL = 30.minutes

  def initialize(query)
    @query = query
  end

  # returns a hash like:
  # { temperature_c: 12.3, temperature_f: 54.1, high_c: ..., low_c: ..., cached: true/false, source: 'openweather' }
  # or { error: '...' } on failure
  def call
    geo = GeocodingService.new(@query).call
    cache_code = geo[:address]["postcode"] || @query
    return { error: geo[:error] } if geo[:error]

    cache_key = "weather:#{cache_code.to_s.downcase.strip}"
    cached_value = Rails.cache.read(cache_key)
    if cached_value.present?
      # return cached with indicator
      return cached_value.merge(cached: true, cached_at: timestamp_from_cache(cache_key))
    end

    # Not cached: fetch from OpenWeather
    weather_raw = fetch_openweather(geo[:lat], geo[:lon])
    return { error: weather_raw[:error] } if weather_raw[:error]

    payload = build_payload(weather_raw, geo[:address])
    # write to cache
    Rails.cache.write(cache_key, payload.merge(cached: true), expires_in: CACHE_TTL)
    # return payload with cached: false to indicate fresh fetch
    payload.merge(cached: false)
  rescue StandardError => e
    { error: "Unexpected error: #{e.message}" }
  end

  private

  def timestamp_from_cache(key)
    # Redis doesn't store timestamps by default. We stored the payload; if you want timestamp,
    # you can include it when writing. For now return Time.current (approx).
    Time.current
  end

  def build_payload(raw, geo)
    temp_k = raw.dig('main', 'temp')
    temp_min_k = raw.dig('main', 'temp_min')
    temp_max_k = raw.dig('main', 'temp_max')

    {
      location: @query.to_s.upcase.strip,
      temperature_c: kelvin_to_c(temp_k),
      temperature_f: kelvin_to_f(temp_k),
      high_c: kelvin_to_c(temp_max_k),
      low_c: kelvin_to_c(temp_min_k),
      fetched_at: Time.at(raw['dt']).utc.iso8601,
      state: geo["state"],
      country: geo["country"],
      postcode: geo["postcode"],
    }
  end

  def fetch_openweather(lat, lon)
    api_key = ENV['OPENWEATHER_API_KEY']
    return { error: 'OPENWEATHER_API_KEY not configured' } unless api_key.present?

    url = "#{ENV['OPENWEATHER_ENDPOINT']}?lat=#{lat}&lon=#{lon}&appid=#{api_key}"
    response = HTTParty.get(url)

    if response.code != 200
      return { error: "OpenWeather returned status #{response.code}: #{response.parsed_response}" }
    end

    response.parsed_response
  rescue StandardError => e
    { error: "Weather API request failed: #{e.message}" }
  end

  def kelvin_to_c(k)
    return nil unless k
    ((k.to_f - 273.15).round(2)).to_f
  end

  def kelvin_to_f(k)
    return nil unless k
    ((k.to_f - 273.15) * 9.0 / 5.0 + 32).round(2).to_f
  end
end
