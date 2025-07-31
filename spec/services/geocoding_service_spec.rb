# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GeocodingService do
  let(:address) { '123 Main St, New York, NY' }
  let(:mock_location) do
    double(
      latitude: 40.7128,
      longitude: -74.0060,
      postal_code: '10001',
      address: 'New York, NY 10001, USA'
    )
  end

  before do
    allow(ErrorHandler).to receive(:handle)
  end

  context 'when geocoding is successful' do
    before do
      allow(ENV).to receive(:fetch).with('GOOGLE_GEOCODER_API_KEY', nil).and_return('dummy-key')
      allow(Geocoder).to receive(:search).with(address).and_return([ mock_location ])
    end

    it 'returns location, coordinates, and zip code' do
      result = described_class.run(address: address)
      expect(result).to be_valid
      expect(result.result[:location]).to eq(mock_location)
      expect(result.result[:coordinates]).to eq([ 40.7128, -74.0060 ])
      expect(result.result[:zip_code]).to eq('10001')
    end
  end

  context 'when geocoding returns empty results and API key is present' do
    before do
      allow(ENV).to receive(:fetch).with('GOOGLE_GEOCODER_API_KEY', nil).and_return('dummy-key')
      allow(Geocoder).to receive(:search).with(address).and_return([])
    end

    it 'adds error and calls handler' do
      expect(ErrorHandler).to receive(:handle).with(hash_including(message: /No location found for address/))
      result = described_class.run(address: address)
      expect(result).not_to be_valid
      expect(result.errors.full_messages.first).to match(/No location found for address/)
    end
  end

  context 'when API key is missing' do
    before do
      allow(ENV).to receive(:fetch).with('GOOGLE_GEOCODER_API_KEY', nil).and_return(nil)
      allow(Geocoder).to receive(:search).with(address).and_return([])
    end

    it 'adds error and calls handler for missing API key' do
      expect(ErrorHandler).to receive(:handle).with(hash_including(message: /Geocoding is not initialized properly/))
      result = described_class.run(address: address)
      expect(result).not_to be_valid
      expect(result.errors.full_messages.first).to match(/Weather Service is not available at this time/)
    end
  end


  context 'with blank address' do
    let(:address) { '' }
    before do
      allow(ENV).to receive(:fetch).with('GOOGLE_GEOCODER_API_KEY', nil).and_return('dummy-key')
      allow(Geocoder).to receive(:search).with(address).and_return([])
    end
    it 'adds error for blank address' do
      result = described_class.run(address: address)
      expect(result).not_to be_valid
      expect(result.errors.full_messages.first).to eq("Address can't be blank")
    end
  end

  context 'with nil address' do
    let(:address) { nil }
    before do
      allow(ENV).to receive(:fetch).with('GOOGLE_GEOCODER_API_KEY', nil).and_return('dummy-key')
      allow(Geocoder).to receive(:search).with(address).and_return([])
    end
    it 'adds error for nil address' do
      result = described_class.run(address: address)
      expect(result).not_to be_valid
      expect(result.errors.full_messages.first).to eq("Address is required")
    end
  end

  context 'when location has no postal_code' do
    let(:mock_location_no_zip) do
      double(
        latitude: 40.7128,
        longitude: -74.0060,
        postal_code: nil,
        address: 'New York, NY, USA'
      )
    end
    before do
      allow(ENV).to receive(:fetch).with('GOOGLE_GEOCODER_API_KEY', nil).and_return('dummy-key')
      allow(Geocoder).to receive(:search).with(address).and_return([ mock_location_no_zip ])
    end
    it 'sets zip_code to nil' do
      result = described_class.run(address: address)
      expect(result).to be_valid
      expect(result.result[:zip_code]).to be_nil
    end
  end

  context 'when location has no coordinates' do
    let(:mock_location_no_coords) do
      double(
        latitude: nil,
        longitude: nil,
        postal_code: '10001',
        address: 'New York, NY 10001, USA'
      )
    end
    before do
      allow(ENV).to receive(:fetch).with('GOOGLE_GEOCODER_API_KEY', nil).and_return('dummy-key')
      allow(Geocoder).to receive(:search).with(address).and_return([ mock_location_no_coords ])
    end
    it 'sets coordinates with nil values' do
      result = described_class.run(address: address)
      expect(result).to be_valid
      expect(result.result[:coordinates]).to eq([ nil, nil ])
    end
  end
end
