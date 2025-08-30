# README

# Weather App

This Rails application retrieves weather information for a given address. It uses a third-party address service to validate and extrapolate latitude and longitude from user-provided address fragments. The app then fetches weather data for those coordinates.

## Features

- Address validation and geocoding using a third-party service
- Weather retrieval by latitude and longitude
- **Scalable presenter-based architecture** designed for future weather forecast features
- **Modular view components** with reusable partials for easy feature expansion
- **30-minute intelligent caching** for both geocoding and weather data
- Modern Rails stack with Tailwind CSS, Turbo, Stimulus, and Importmap
- RSpec, FFaker, and Shoulda Matchers for testing
- Rubocop and Lefthook for code quality and pre-commit checks
- Environment variable management with dotenv

## Architecture & Scalability

This application is built with future expansion in mind, particularly for adding weather forecast capabilities:

### **Presenter Pattern for Data Management**
- **`GeocodingPresenter`**: Handles address validation and coordinate data with clean `presenter.valid?` interface
- **`WeatherPresenter`**: Manages current weather data with methods like `temperature_display`, `full_location_name`, and `condition_icon_url`
- **Future-Ready**: Presenter pattern easily extends to `WeatherForecastPresenter` for multi-day forecasts

### **Modular View Components**
- **`_weather_details` partial**: Accepts `weather_presenter` as local variable, designed for reusability
- **Scalability Focus**: The weather_details component can easily display:
  - Current weather (implemented)
  - 5-day forecasts (future)
  - Hourly forecasts (future)
  - Weather alerts (future)
- **`_notifications` partial**: Reusable flash message component for consistent UX

### **Service Layer Architecture**
- **`Geocoding::LookupService`**: Isolated geocoding logic with caching
- **`Weather::FetcherService`**: Weather API integration with structured responses
- **Extensible**: New services like `Weather::ForecastService` can be added without touching existing code

### **Performance & Caching Strategy**
- **30-minute cache expiration** for both geocoding and weather data
- **Cache hit detection** with user-friendly notifications
- **Memory-efficient**: Presenter objects only created when needed
- **Future-Ready**: Caching strategy supports forecast data with different TTL requirements

## Future Roadmap

The application architecture is specifically designed to support these planned features:

### **Weather Forecasts**
- **5-Day Weather Forecasts**: Reuse existing `_weather_details` partial with `WeatherForecastPresenter`
- **Hourly Forecasts**: Same modular approach with time-based data presentation
- **Weather Trends**: Historical data integration using established presenter pattern

### **Enhanced User Experience**
- **Location Favorites**: Leverage existing geocoding cache for saved locations
- **Weather Alerts**: Extend notification system for severe weather warnings
- **Multi-Location Dashboard**: Scale the weather_details component for multiple locations

### **API & Data Expansion**
- **Multiple Weather Sources**: Service layer supports easy provider switching
- **Radar Data**: Image-based weather data using existing presenter approach
- **Air Quality Index**: Additional data streams following established patterns

**Key Design Decision**: The `_weather_details` partial accepts `weather_presenter` as a local variable rather than relying on instance variables, making it perfectly suited for rendering multiple weather components (current + forecast) on the same page without variable conflicts.

## Environment Variables

This application requires two API keys to function properly:

### Google Geocoding API Key (`ADDRESS_API_KEY`)
- **Purpose**: Converts user-entered addresses into latitude/longitude coordinates
- **Service**: Google Geocoding API
- **Setup**:
  1. Go to [Google Cloud Console](https://console.cloud.google.com/)
  2. Enable the Geocoding API
  3. Create credentials and copy the API key
  4. Add to `.env` as `ADDRESS_API_KEY=your_google_api_key`

### Weather API Key (`WEATHER_API_KEY`)
- **Purpose**: Retrieves current weather data for coordinates
- **Service**: WeatherAPI.com
- **Setup**:
  1. Sign up at [WeatherAPI.com](https://www.weatherapi.com/)
  2. Get your free API key from the dashboard
  3. Add to `.env` as `WEATHER_API_KEY=your_weather_api_key`

**Example `.env` file:**
```bash
ADDRESS_API_KEY=your_google_api_key
WEATHER_API_KEY=your_weather_api_key
```

## Setup

1. **Clone the repository**
2. **Install dependencies**
	```bash
	bundle install
	```
3. **Set up environment variables**
	- Copy `.env.example` to `.env` and fill in required API keys:
	  - `ADDRESS_API_KEY`: Google Geocoding API key for address validation and coordinate lookup
	  - `WEATHER_API_KEY`: WeatherAPI.com API key for weather data retrieval
4. **Set up the database**
	```bash
	bin/rails db:setup
	```
5. **Run the application**
	```bash
	bin/rails server
	```

## Usage

1. Enter an address or address fragment in the app interface.
2. The app validates and geocodes the address using the third-party service.
3. Weather data is retrieved for the resulting latitude and longitude.

## Testing

The application includes comprehensive test coverage with both unit and feature tests:

- **Unit Tests**: Service objects and presenters are tested in isolation with mocked API responses
- **Presenter Tests**: Complete coverage of `GeocodingPresenter` and `WeatherPresenter` data handling and validation logic
- **Feature Tests**: Full browser tests using Selenium WebDriver with Chrome in headless mode
- **Test Framework**: RSpec with FFaker and Shoulda Matchers
- **Browser Testing**: Capybara with Selenium WebDriver for JavaScript-enabled features
- **Code Coverage**: SimpleCov with Codecov integration for coverage reporting

### Running Tests

Run the full test suite:
```bash
bundle exec rspec
```

Run tests with coverage report:
```bash
# Local coverage report (generates HTML report in coverage/)
./bin/coverage

# Or manually with environment variable
COVERAGE=true bundle exec rspec
```

Run only unit tests (faster):
```bash
bundle exec rspec spec/services/ spec/presenters/
```

Run only feature tests:
```bash
bundle exec rspec spec/features/
```

Run tests with documentation format:
```bash
bundle exec rspec --format documentation
```

### Browser Testing

Feature tests use Selenium WebDriver with Chrome and support both headless and visible browser modes:

**Test Coverage:**
- Search functionality with valid addresses
- Error handling for invalid addresses
- UI interactions and content display
- Weather data presentation including temperature and conditions

**Browser Testing Modes:**

1. **Headless Mode (Default - Fast)**
   ```bash
   # Regular headless testing
   bundle exec rspec spec/features/
   ```

2. **Visible Browser Mode (Debugging)**
   ```bash
   # See browser window during tests
   SHOW_BROWSER=true bundle exec rspec spec/features/weather_search_spec.rb
   ```

3. **Step-by-Step Debugging**
   ```bash
   # Visible browser with pause after each test
   SHOW_BROWSER=true PAUSE_AFTER_STEPS=5 bundle exec rspec spec/features/weather_search_spec.rb
   ```

4. **Single Test Debugging**
   ```bash
   # Run specific test with visible browser
   SHOW_BROWSER=true rspec spec/features/weather_search_spec.rb:12
   ```

**Environment Variables:**
- `SHOW_BROWSER=true` - Opens visible Chrome window during tests
- `PAUSE_AFTER_STEPS=N` - Pauses N seconds after each test (requires SHOW_BROWSER=true)
- `CAPYBARA_DEBUG=true` - Enables screenshots and additional debugging features

### Testing Best Practices

**Development Workflow:**
1. Use headless mode for regular TDD cycles (fastest)
2. Use visible browser mode when debugging test failures
3. Use pause mode to observe step-by-step test execution
4. Service tests run independently of browser tests for quick feedback

**Debugging Tips:**
- Set `SHOW_BROWSER=true` to see what the browser is actually doing
- Use `PAUSE_AFTER_STEPS=10` to inspect the final state after test completion
- Check `tmp/capybara/` directory for screenshots when `CAPYBARA_DEBUG=true`
- Feature tests mock API calls to avoid external dependencies

**Test Structure:**
- Unit tests (`spec/services/`) - Fast, isolated, no browser
- Presenter tests (`spec/presenters/`) - Data handling and validation logic
- Feature tests (`spec/features/`) - Full integration, browser automation
- All tests use realistic mock data matching actual API responses

### Code Coverage

The project uses **SimpleCov** with **Codecov** integration for comprehensive test coverage reporting:

**Local Coverage:**
```bash
# Generate HTML coverage report
./bin/coverage

# View report in browser
open coverage/index.html
```

**CI Coverage:**
- Automatic coverage reporting on GitHub Actions
- Results uploaded to Codecov for tracking over time
- Coverage thresholds enforced (85% overall, 70% per file)

**Coverage Configuration:**
- **Tracked**: Controllers, Models, Services, Presenters, Helpers, Jobs, Mailers
- **Excluded**: Config files, specs, migrations, vendor code
- **Thresholds**: 85% overall coverage, 70% minimum per file
- **Branch Coverage**: Enabled for Ruby 2.5+

**Codecov Setup (for maintainers):**
1. Sign up at [codecov.io](https://codecov.io) and link your GitHub repository
2. Add `CODECOV_TOKEN` secret to your GitHub repository settings
3. Coverage reports are automatically uploaded via GitHub Actions on every push/PR
4. View coverage trends and file-by-file coverage at your Codecov dashboard

## Code Quality

- Rubocop runs automatically before each commit via Lefthook.
- To run manually:
  ```bash
  bundle exec rubocop
  ```

## Configuration

- All sensitive keys and configuration should be placed in `.env`.
- Tailwind CSS is managed via the `tailwindcss-rails` gem.

## Architecture

- Rails 8
- Tailwind CSS
- Turbo, Stimulus, Importmap
- RSpec, FFaker, Shoulda Matchers
- Rubocop, Lefthook
- dotenv

## Deployment

Standard Rails deployment. Ensure environment variables are set on your server.

## License

MIT
