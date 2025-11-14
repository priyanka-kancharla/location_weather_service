require 'test_helper'
require 'webmock/minitest'
require 'geocoder_helper'

class WeatherFetcherTest < ActiveSupport::TestCase
  def setup
    @result = WeatherFetcher.new('90210').call
  end

  test "returns temperature and high/low" do
    assert_in_delta 6.85, @result[:temperature_c], 0.01
    assert_in_delta 10.0, @result[:high_c], 0.01
    assert_in_delta 3.0, @result[:low_c], 0.01
    assert_equal false, @result[:cached]
    assert_equal '534260', @result[:location]
  end

end
