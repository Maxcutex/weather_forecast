# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'json'

# Initializes a new WeatherService instance
# @param zip [String] zip code of the location
# @param lat [Float] latitude of the location
# @param lon [Float] longitude of the location
class WeatherService < ActiveInteraction::Base
  float :lat
  float :lon

  validates :lat, :lon, presence: true
  validate :validate_api_key
  validate :validate_endpoint

  def execute
    fetch
  end

  private

  def fetch
    uri = build_uri
    response = Net::HTTP.get_response(uri)
    return handle_api_error(response, uri) unless response.is_a?(Net::HTTPSuccess)

    parse_json_response(response, uri)
  end

  def build_uri
    URI("#{@endpoint}?lat=#{@lat}&lon=#{@lon}&appid=#{@api_key}&units=imperial")
  end

  def parse_json_response(response, _uri)
    JSON.parse(response.body)
  end

  def handle_api_error(response, uri)
    add_generic_error
    ErrorHandler.handle(message: "Weather API error: #{response.code} #{response.message} #{uri}",
                        status: response.code.to_i)
  end

  def validate_api_key
    @api_key = ENV.fetch('OPENWEATHER_API_KEY', nil)
    return if @api_key.present?

    add_generic_error
    ErrorHandler.handle(message: 'Webservice API key missing ')
  end

  def validate_endpoint
    @endpoint = ENV.fetch('OPENWEATHER_ENDPOINT', nil)
    return if @endpoint.present?

    add_generic_error
    ErrorHandler.handle(message: 'Webservice endpoint missing ')
  end

  def add_generic_error
    errors.add(:base, 'Weather Service is not available at this time. Please try again later.')
  end
end
