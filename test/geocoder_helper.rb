require 'ostruct'

# Stub Geocoder globally
module Geocoder
  def self.search(_query)
    [OpenStruct.new(
      latitude: 1.0,
      longitude: 1.0,
      address: 'X',
      data: { 'address' => { 'postcode' => '534260' } }
    )]
  end
end

# Monkey-patch WeatherFetcher globally
WeatherFetcher.class_eval do
  define_method(:call) do
    {
      temperature_c: 6.85,
      high_c: 10.0,
      low_c: 3.0,
      cached: false,
      location: '534260',
      state: 'Andhra Pradesh',
      country: 'India',
      postcode: '534260'
    }
  end
end
