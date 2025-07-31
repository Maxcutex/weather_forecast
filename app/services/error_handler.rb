# frozen_string_literal: true

# ErrorHandler: Centralized error handling for logging and notifications
class ErrorHandler
  def self.handle(message:, status: nil, details: {})
    error = ServiceError.new(message, status, details)
    log_error(error)
    ErrorNotification.notify(error)
  rescue StandardError
    # Fail silently if error handling itself fails
  end

  def self.log_error(error)
    return unless error

    status = error.respond_to?(:status) ? error.status : ''
    details = error.respond_to?(:details) ? error.details : ''
    Rails.logger.error("[ErrorHandler] #{error.class}: #{error.message} | Status: #{status} | Details: #{details}")
  rescue StandardError
    # Fail silently if logging fails
  end
end
