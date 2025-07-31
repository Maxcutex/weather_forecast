# frozen_string_literal: true

# ForecastService: Encapsulates forecast logic for address to coordinates/zip conversion
class ForecastService < ActiveInteraction::Base
  string :address
  validates :address, presence: true

  def execute
    fetch_from_cache.presence || fetch_and_cache_forecast
  end

  private

  # @return [Hash] geocode data
  def geocode
    @geocode ||= compose(GeocodingService, address: address)
  end

  # @return [String] cache key
  def cache_key
    @cache_key ||= "forecast_#{geocode[:zip_code]}"
  end

  def fetch_from_cache
    forecast_hash = Rails.cache.read(cache_key)
    return if forecast_hash.blank?

    Dtos::Forecast.new(**forecast_hash, from_cache: true)
  end

  def fetch_and_cache_forecast
    weather = compose(WeatherService, lat: geocode[:coordinates][0], lon: geocode[:coordinates][1])
    forecast = Dtos::Forecast.new(
      address: address,
      location: geocode[:location],
      coordinates: geocode[:coordinates],
      zip_code: geocode[:zip_code],
      weather: weather,
      from_cache: false
    )
    Rails.cache.write(cache_key, forecast.to_h, expires_in: 30.minutes)

    forecast
  end
end
