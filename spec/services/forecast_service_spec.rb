# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ForecastService do
  let(:address) { '123 Main St, New York, NY' }
  let(:zip_code) { '10001' }
  let(:cache_key) { "forecast_#{zip_code}" }
  let(:location) { double('Geocoder::Result', latitude: 40.7128, longitude: -74.0060, postal_code: zip_code, address: 'New York, NY 10001, USA') }
  let(:coordinates) { [ 40.7128, -74.0060 ] }
  let(:weather) { double('WeatherResult', valid?: true) }
  let(:forecast_hash) do
    {
      address: address,
      location: location,
      coordinates: coordinates,
      zip_code: zip_code,
      weather: weather,
      from_cache: true
    }
  end

  describe '#run' do
    context 'when forecast exists in cache' do
      before do
        allow_any_instance_of(GeocodingService).to receive(:valid?).and_return(true)
        allow_any_instance_of(GeocodingService).to receive(:execute).and_return({ location: location, coordinates: coordinates, zip_code: zip_code })
        allow(Rails.cache).to receive(:read).with(cache_key).and_return(forecast_hash)
      end

      it 'returns a Dtos::Forecast loaded from cache' do
        result = described_class.run(address: address)
        expect(result).to be_valid
        expect(result.result).to be_a(Dtos::Forecast)
        expect(result.result.from_cache).to be true
        expect(result.result.address).to eq(address)
      end
    end

    context 'when forecast does not exist in cache' do
      before do
        allow_any_instance_of(GeocodingService).to receive(:valid?).and_return(true)
        allow_any_instance_of(GeocodingService).to receive(:execute).and_return({ location: location, coordinates: coordinates, zip_code: zip_code })
        allow(Rails.cache).to receive(:read).with(cache_key).and_return(nil)
        allow_any_instance_of(WeatherService).to receive(:valid?).and_return(true)
        allow_any_instance_of(WeatherService).to receive(:execute).and_return(weather)
        allow(Rails.cache).to receive(:write)
      end

      it 'fetches and caches a new forecast' do
        result = described_class.run(address: address)
        expect(result).to be_valid
        expect(result.result).to be_a(Dtos::Forecast)
        expect(result.result.from_cache).to be false
        expect(result.result.address).to eq(address)
        expect(Rails.cache).to have_received(:write).with(cache_key, kind_of(Hash), expires_in: 30.minutes)
      end
    end

    context 'when geocoding is invalid' do
      before do
        allow(Geocoder).to receive(:search).and_return([])
        allow(Rails.cache).to receive(:read).and_return(nil)
      end

      it 'returns an invalid outcome with geocoding errors' do
        result = described_class.run(address: address)
        expect(result).not_to be_valid
        expect(result.errors.full_messages.first).to match(/No location found for address: 123 Main St, New York, NY/)
      end
    end

    context 'when weather is invalid' do
      let(:geocode_result) { { location: location, coordinates: coordinates, zip_code: zip_code } }
      let(:geocode_outcome) { double(valid?: true, result: geocode_result, :[] => geocode_result[:zip_code]) }

      before do
        allow_any_instance_of(ForecastService).to receive(:compose)
          .with(GeocodingService, address: address).and_return(geocode_outcome)
        allow_any_instance_of(ForecastService).to receive(:compose)
          .with(WeatherService, any_args).and_call_original
        allow(Rails.cache).to receive(:read).with(cache_key).and_return(nil)
        allow(Rails.cache).to receive(:write)
        allow(ENV).to receive(:fetch).with('OPENWEATHER_API_KEY', nil).and_return(nil)
        allow(ENV).to receive(:fetch).with('OPENWEATHER_ENDPOINT', nil).and_return(nil)
      end

      it 'returns an invalid outcome with weather service error' do
        result = described_class.run(address: address)
        expect(result).not_to be_valid
        expect(result.errors.full_messages.first).to match(/Weather Service is not available at this time. Please try again later./)
      end
    end

    context 'when cache write fails' do
      before do
        allow_any_instance_of(GeocodingService).to receive(:valid?).and_return(true)
        allow_any_instance_of(GeocodingService).to receive(:execute).and_return({ location: location, coordinates: coordinates, zip_code: zip_code })
        allow(Rails.cache).to receive(:read).with(cache_key).and_return(nil)
        allow_any_instance_of(WeatherService).to receive(:valid?).and_return(true)
        allow_any_instance_of(WeatherService).to receive(:execute).and_return(weather)
        allow(Rails.cache).to receive(:write).and_raise(StandardError.new('Cache write failed'))
      end

      it 'raises error but still returns forecast' do
        expect {
          described_class.run(address: address)
        }.to raise_error(StandardError, 'Cache write failed')
      end
    end

    context 'when address is blank' do
      it 'is invalid and returns validation error' do
        result = described_class.run(address: '')
        expect(result).not_to be_valid
        expect(result.errors.full_messages).to include("Address can't be blank")
      end
    end
  end
end
