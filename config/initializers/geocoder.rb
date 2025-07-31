# Configure Geocoder to use Google Maps Geocoding API
Geocoder.configure(
  lookup: :google,
  api_key: ENV["GOOGLE_GEOCODER_API_KEY"],
  timeout: 5,
  units: :mi
)
