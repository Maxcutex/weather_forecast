# frozen_string_literal: true

# GeocodingService: Encapsulates geocoding logic for address to coordinates/zip conversion
class GeocodingService < ActiveInteraction::Base
  string :address

  validates :address, presence: true
  validate :check_api_key_presence!

  def execute
    lookup
  end

  private

  def lookup
    results = Geocoder.search(@address)

    return handle_no_location_found! if results.blank?

    handle_success(results)
  end

  def check_api_key_presence!
    api_key = ENV.fetch('GOOGLE_GEOCODER_API_KEY', nil)
    return if api_key.present?

    errors.add(:base, 'Weather Service is not available at this time. Please try again later.')
    error_message = 'Geocoding is not initialized properly. Please check your Google Maps API key.'
  end

  def handle_success(results)
    @location = results.first
    @coordinates = [@location.latitude, @location.longitude]
    @zip_code = @location.postal_code
    {
      location: @location,
      coordinates: @coordinates,
      zip_code: @zip_code,
    }
  end

  def handle_no_location_found!
    errors.add(:base, "No location found for address: #{@address}")
    error_message = "Geocoding error: No location found for address: #{@address}"
  end
end
