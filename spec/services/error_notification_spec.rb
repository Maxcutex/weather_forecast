# frozen_string_literal: true

require "rails_helper"

RSpec.describe ErrorNotification do
  let(:error) { StandardError.new("something broke") }

  context "when Sentry is defined" do
    it "captures the exception" do
      sentry_double = class_double("Sentry", capture_exception: nil)
      stub_const("Sentry", sentry_double)

      described_class.notify(error)

      expect(sentry_double).to have_received(:capture_exception).with(error)
    end

    it "rescues if Sentry raises" do
      sentry_double = class_double("Sentry")
      stub_const("Sentry", sentry_double)
      allow(sentry_double).to receive(:capture_exception).and_raise("sentry down")

      expect {
        described_class.notify(error)
      }.not_to raise_error
    end
  end

  context "when Sentry is not defined" do
    it "does nothing and does not raise" do
      hide_const("Sentry") # ensures constant is undefined for this example

      expect {
        described_class.notify(error)
      }.not_to raise_error
    end
  end
end
