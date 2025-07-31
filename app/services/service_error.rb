# frozen_string_literal: true

# ServiceError: Custom error class for handling service errors in geocoding, weather, and forecast services
class ServiceError < StandardError
  attr_reader :status, :details

  # @param message [String] error message
  # @param status [Integer] HTTP status code
  # @param details [Hash] additional error details
  def initialize(message = nil, status: 500, details: {})
    super(message)
    @status = status
    @details = details
  end
end
