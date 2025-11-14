class GeocodingService
  # returns { lat: float, lon: float, normalized: "zip|address string" }
  # or { error: '...' } on failure
  def initialize(query)
    @query = query
  end

  def call
    # Geocoder.search returns result objects
    results = Geocoder.search(@query)
    if results.blank?
      { error: "Could not geocode query: #{@query}" }
    else
      first = results&.first
    #   normalized = normalized_key(first)
      { lat: first&.latitude.to_f, lon: first&.longitude.to_f, address: first&.data["address"],  }
    end
  rescue StandardError => e
    { error: "Geocoding failed: #{e.message}" }
  end
end
