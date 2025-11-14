A Ruby on Rails application that provides weather forecasts for a given ZIP code, address, or place.  
The app uses **Geocoder** to fetch latitude/longitude from the input, **OpenWeatherMap API** for weather data, and **Redis** for caching.

---

## Features

- Accepts ZIP codes, place names, or full addresses as input
- Returns:
  - Current temperature (°C and °F)
  - High and low temperatures
  - State and country
  - Postal code (if available)
- Caches weather results for **30 minutes** using Redis
- Indicates whether results are retrieved from cache
- Handles errors gracefully (invalid input, API errors, missing API key)
- Supports both **HTML view rendering** and **JSON API** responses

---

## Requirements

- Ruby 3.4+
- Rails 8+
- Redis server
- Bundler
- OpenWeatherMap API key
- Geocoder API key

---

## Setup

1. Clone the repository:

```bash
git clone <your_repo_url>
cd location_weather_service
````

2. Install dependencies:

```bash
bundle install
```

3. Create a `.env` file in the project root with your API keys:

```env
OPENWEATHER_API_KEY=your_openweather_api_key
GEOCODER_API_KEY=your_geocoder_api_key
OPENWEATHER_ENDPOINT=https://api.openweathermap.org/data/2.5/weather
```

4. Start Redis server:

```bash
redis-server
```

5. Start Rails server:

```bash
rails server
```

6. Open your browser at [http://localhost:3000](http://localhost:3000)

---

## Usage

### Web UI

1. Enter a ZIP code, city, or address in the input field.
2. Click **Get Weather**.
3. The page displays:

   * Current temperature (C/F)
   * High/Low temperatures
   * State and country
   * Postal code (if available)
4. If the result is cached, `cached: true` is returned internally.

### JSON API

Send a GET request to `/forecast?q=<your_query>`:

```bash
curl "http://localhost:3000/forecast?q=534260" -H "Accept: application/json"
```

Example response:

```json
{
  "location": "534260",
  "temperature_c": 6.85,
  "temperature_f": 44.33,
  "high_c": 10.0,
  "low_c": 3.0,
  "state": "Andhra Pradesh",
  "country": "India",
  "postcode": "534260",
  "cached": false,
  "fetched_at": "2025-11-14T10:22:06Z"
}
```

---

## Testing

* Uses **Minitest**.
* Test files are in `test/services` and `test/controllers`.
* To run all tests:

```bash
rails test
```

* To run a specific test file:

```bash
rails test test/controllers/weather_controller_test.rb
```

* Stubs are provided for Geocoder and WeatherFetcher in tests to avoid calling real APIs.

---

## Architecture & Design

* **MVC**: Rails controller handles input/output; service object (`WeatherFetcher`) encapsulates business logic.
* **Services**:

  * `GeocodingService`: Converts address/place/zip to latitude and longitude.
  * `WeatherFetcher`: Fetches weather data and handles caching.
* **Caching**:

  * Redis is used for storing results per normalized location (ZIP or normalized address).
  * Cached data expires in **30 minutes**.
* **Error handling**:

  * Invalid queries, missing API keys, and external API errors are handled gracefully.
* **Testing**:

  * Uses **stubs** for external services in tests.
  * Focuses on backend logic (unit tests) rather than frontend behavior.

---

## Notes

* Functionality is prioritized over UI design.
* All temperature conversions use Kelvin → Celsius/Fahrenheit formulas.
* `fetched_at` indicates when the weather data was retrieved.
