# frozen_string_literal: true

# ErrorNotification: Handles external error notification (e.g., Sentry)
class ErrorNotification
  def self.notify(error)
    Sentry.capture_exception(error) if defined?(Sentry)
  rescue StandardError
    # Fail silently if notification fails
  end
end
