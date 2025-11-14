# test/controllers/weather_controller_test.rb
require 'test_helper'
require 'webmock/minitest'
require 'json'
require 'geocoder_helper'


class WeatherControllerTest < ActionDispatch::IntegrationTest
  test "forecast without q param returns ok" do
    get forecast_url
    assert_response :success
  end

  test "forecast with q param returns ok" do
    get forecast_url, params: { q: '534260' }

    assert_response :success
     assert_select 'div#weather-result' do
      assert_select 'h3', text: /Forecast for 534260/
      assert_select 'p', text: /Temperature: 6.85 °C/
      assert_select 'p', text: /High Temperature: 10.0 °C/
      assert_select 'p', text: /Low Temperature: 3.0 °C/
      assert_select 'p', text: /Postal Code: 534260/
      assert_select 'p', text: /State: Andhra Pradesh/
      assert_select 'p', text: /Country: India/
    end
  end
end