# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ServiceError do
  let(:message) { 'Something went wrong' }
  let(:status) { 422 }
  let(:details) { { context: 'test' } }

  it 'inherits from StandardError' do
    expect(described_class).to be < StandardError
  end

  it 'sets message, status, and details on initialization' do
    error = described_class.new(message, status: status, details: details)
    expect(error.message).to eq(message)
    expect(error.status).to eq(status)
    expect(error.details).to eq(details)
  end

  it 'defaults status to 500 and details to {}' do
    error = described_class.new(message)
    expect(error.status).to eq(500)
    expect(error.details).to eq({})
  end

  it 'can be raised and rescued as StandardError' do
    expect {
      raise described_class.new(message, status: status, details: details)
    }.to raise_error(StandardError, message)
  end
end
