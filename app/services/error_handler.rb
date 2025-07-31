# frozen_string_literal: true

# ErrorHandler: Centralized error handling for logging and notifications
class ErrorHandler
  # @param message [String] error message
  # @param status [Integer] HTTP status code
  # @param details [Hash] additional error details
  def self.handle(message:, status: nil, details: {})
    error = ServiceError.new(message, status, details)
    log_error(error)
    ErrorNotification.notify(error)
  rescue StandardError
    # Fail silently if error handling itself fails
  end

  # @param error [ServiceError] error object
  def self.log_error(error)
    return unless error

    status = error.respond_to?(:status) ? error.status : ''
    details = error.respond_to?(:details) ? error.details : ''
    Rails.logger.error("[ErrorHandler] #{error.class}: #{error.message} | Status: #{status} | Details: #{details}")
  rescue StandardError
    # Fail silently if logging fails
  end
end
