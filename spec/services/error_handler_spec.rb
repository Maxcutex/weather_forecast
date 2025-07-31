# frozen_string_literal: true

require "rails_helper"

RSpec.describe ErrorHandler do
  # Provide a minimal implementation for ServiceError used by ErrorHandler
  before do
    stub_const(
      "ServiceError",
      Class.new(StandardError) do
        attr_reader :status, :details
        def initialize(message, status = nil, details = {})
          super(message)
          @status = status
          @details = details
        end
      end
    )
  end

  describe ".handle" do
    it "builds a ServiceError and logs and notifies" do
      # Arrange
      allow(described_class).to receive(:log_error)
      allow(ErrorNotification).to receive(:notify)

      # Act
      described_class.handle(message: "Boom!", status: 422, details: { foo: "bar" })

      # Assert
      expect(described_class).to have_received(:log_error).with(instance_of(ServiceError))
      expect(ErrorNotification).to have_received(:notify).with(instance_of(ServiceError))
    end

    it "does not raise if notification itself raises" do
      allow(described_class).to receive(:log_error)
      allow(ErrorNotification).to receive(:notify).and_raise("notify failed")

      expect {
        described_class.handle(message: "Boom!")
      }.not_to raise_error
    end
  end

  describe ".log_error" do
    let(:logger_double) { instance_double(Logger, error: nil) }

    before do
      allow(Rails).to receive(:logger).and_return(logger_double)
    end

    it "logs a formatted message including class, message, status, and details" do
      err = ServiceError.new("Boom!", 503, { service: "payments" })

      described_class.log_error(err)

      expect(logger_double).to have_received(:error).with(
        a_string_matching(/\[ErrorHandler\] ServiceError: Boom! \| Status: 503 \| Details: {:service=>"payments"}/)
      )
    end

    it "uses blank strings for status/details when not available" do
      # StandardError does not respond_to? :status / :details
      err = StandardError.new("Oops")

      described_class.log_error(err)

      expect(logger_double).to have_received(:error).with(
        "[ErrorHandler] StandardError: Oops | Status:  | Details: "
      )
    end

    it "does nothing when error is nil" do
      described_class.log_error(nil)
      expect(logger_double).not_to have_received(:error)
    end

    it "fails silently if logger itself raises" do
      err = ServiceError.new("Boom!")
      allow(logger_double).to receive(:error).and_raise("logger down")

      expect {
        described_class.log_error(err)
      }.not_to raise_error
    end
  end
end
