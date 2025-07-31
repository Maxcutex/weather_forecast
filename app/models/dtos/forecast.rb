# frozen_string_literal: true

module Dtos
  # Forecast: Data Transfer Object for weather forecast
  class Forecast
    # @param address [String] address of the location
    attr_reader :address

    # @param location [Object] location object
    attr_reader :location

    # @param coordinates [Array] coordinates of the location
    attr_reader :coordinates

    # @param zip_code [String] zip code of the location
    attr_reader :zip_code

    # @param weather [Object] weather object
    attr_reader :weather

    # @param from_cache [Boolean] whether the forecast was fetched from cache
    attr_reader :from_cache

    def initialize(address:, location:, coordinates:, zip_code:, weather:, from_cache:)
      @address = address
      @location = location
      @coordinates = coordinates
      @zip_code = zip_code
      @weather = weather
      @from_cache = from_cache
    end

    def to_h
      {
        address: @address,
        location: @location,
        coordinates: @coordinates,
        zip_code: @zip_code,
        weather: @weather,
        from_cache: @from_cache,
      }
    end
  end
end
