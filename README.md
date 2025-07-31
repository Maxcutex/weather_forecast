# Weather Forecast Rails App

A Ruby on Rails application that provides weather forecasts for user-supplied addresses, with caching, error handling, and a modern UI. Integrates with OpenWeatherMap and Google Geocoding APIs.

---

## Features

- Enter any address to get the current weather and extended forecast
- Caches results by zip code for 30 minutes
- Displays if results are fresh or from cache
- Robust error handling and user feedback
- Clean, modern UI (Bootstrap via CDN + custom CSS)
- Centralized service objects for geocoding and weather
- Fully tested with RSpec
- Ready for Docker deployment

---

## Getting Started

### Prerequisites

- Ruby 3.2+
- Rails 7+
- Bundler
- Docker (optional)
- Sentry (To be implemented in the future)
- [OpenWeatherMap API key](https://openweathermap.org/api)
- [Google Geocoding API key](https://developers.google.com/maps/documentation/geocoding/get-api-key)

### Setup

```sh
# Clone the repo
$ git clone https://github.com/Maxcutex/weather_forecast
$ cd weather_forecast

# Install dependencies
$ bundle install

# Copy and edit environment variables
$ cp env.example .env
# Edit .env to add your API keys

# Set up the database (if needed, not used in this app)
$ rails db:setup

# Precompile assets (for production)
$ rails assets:precompile
```

### Running the App

```sh
$ rails server
```

Visit [http://localhost:3000](http://localhost:3000)

---

## Environment Variables

See `.env.example` for all required variables:

- `OPENWEATHER_API_KEY` - Your OpenWeatherMap API key
- `OPENWEATHER_ENDPOINT` - Weather API endpoint (default provided)
- `GOOGLE_GEOCODER_API_KEY` - Your Google Maps Geocoding API key
- `SENTRY_DSN` - Your Sentry DSN (To be implemented in the future)
- `REDIS_URL` - Your Redis URL (production only)

---

## Running Tests

```sh
$ bundle exec rspec
```

---

## Docker

Run the app in Docker:

```sh
$ docker-compose up --build
```

---

## Deployment & CI/CD

- Ready for deployment on Heroku, Render, or any Rails-ready host
- Example GitHub Actions workflow for CI/CD included (if present)

---

## Project Structure & Design

- `app/services/` — Service objects for geocoding, weather, errors
- `app/models/dtos/` — Data Transfer Objects for weather forecast
- `app/controllers/` — Thin controllers, all logic in services
- `app/helpers/` — View helpers for weather/geocoding display
- `spec/` — RSpec unit and integration tests
- `config/locales/` — All user-facing strings in i18n

---

## Scalability

This app is built with scalability in mind:

- **Service Objects**: All external API and business logic is encapsulated in service objects, making it easy to scale horizontally or add background jobs.
- **Caching**: Weather results are cached by zip code for 30 minutes, reducing API calls and improving performance. The cache store can be swapped for Redis in production.
- **Stateless Containers**: The app runs in Docker containers; scale out by running more containers behind a load balancer.
- **Externalized Configuration**: All secrets and endpoints are managed via environment variables for easy deployment in any environment.
- **Redis**: Easily swap to managed Redis services for high availability.
- **Error Handling**: Centralized error handling and logging can be extended to use external monitoring (Sentry, Datadog, etc).
- **UI/UX**: The UI is lightweight and fast, and can be further optimized with CDN asset hosting.
- **Rate Limiting**: Implemented using Rack::Attack to limit requests to 10 per minute per IP.

**Further scaling:**

- Use a CDN for static assets and API response caching.
- Use a distributed cache store (Redis Cluster, Memcached) for large-scale deployments.

---

## License

MIT

---

## Authors

- [Jay Bassey](https://github.com/maxcutex)

---

## Acknowledgements

- OpenWeatherMap
- Google Maps Geocoding
- Rails & Bootstrap
