# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WeatherService do
  let(:lat) { 40.7128 }
  let(:lon) { -74.0060 }
  let(:api_key) { 'test_api_key' }
  let(:endpoint) { 'https://api.openweathermap.org/data/2.5/weather' }
  let(:weather_data) do
    {
      'name' => 'New York',
      'main' => {
        'temp' => 72.5,
        'feels_like' => 75.0,
        'temp_min' => 68.0,
        'temp_max' => 78.0,
        'humidity' => 65
      },
      'weather' => [
        {
          'description' => 'clear sky',
          'icon' => '01d'
        }
      ],
      'wind' => {
        'speed' => 5.2
      }
    }
  end

  before do
    allow(ENV).to receive(:fetch).with('OPENWEATHER_API_KEY', nil).and_return(api_key)
    allow(ENV).to receive(:fetch).with('OPENWEATHER_ENDPOINT', nil).and_return(endpoint)
    allow(ErrorHandler).to receive(:handle)
  end

  describe '#execute' do
    let(:service) { described_class.new(lat: lat, lon: lon) }

    it 'returns parsed weather data on success' do
      mock_response = double('Net::HTTPSuccess')
      allow(mock_response).to receive(:is_a?).with(Net::HTTPSuccess).and_return(true)
      allow(mock_response).to receive(:body).and_return(weather_data.to_json)
      allow(Net::HTTP).to receive(:get_response).and_return(mock_response)
      result = service.execute
      expect(result).to eq(weather_data)
    end

    it 'handles API error response' do
      error_response = double('Net::HTTPBadRequest', code: '400', message: 'Bad Request', body: 'Invalid API key')
      allow(error_response).to receive(:is_a?).with(Net::HTTPSuccess).and_return(false)
      allow(Net::HTTP).to receive(:get_response).and_return(error_response)
      expect(ErrorHandler).to receive(:handle).with(hash_including(message: /Weather API error: 400 Bad Request/))
      expect { service.execute }.to_not raise_error # Service handles error and adds to errors
      expect(service.errors).not_to be_empty
    end


    it 'adds error if API key is missing' do
      allow(ENV).to receive(:fetch).with('OPENWEATHER_API_KEY', nil).and_return(nil)
      missing_key_service = described_class.new(lat: lat, lon: lon)
      expect(ErrorHandler).to receive(:handle).with(hash_including(message: /API key missing/))
      missing_key_service.valid?
      expect(missing_key_service.errors).not_to be_empty
    end

    it 'adds error if endpoint is missing' do
      allow(ENV).to receive(:fetch).with('OPENWEATHER_ENDPOINT', nil).and_return(nil)
      missing_endpoint_service = described_class.new(lat: lat, lon: lon)
      expect(ErrorHandler).to receive(:handle).with(hash_including(message: /endpoint missing/))
      missing_endpoint_service.valid?
      expect(missing_endpoint_service.errors).not_to be_empty
    end

    it 'adds validation errors if lat/lon missing' do
      invalid_service = described_class.new(lat: nil, lon: nil)
      invalid_service.valid?
      expect(invalid_service.errors[:lat]).not_to be_empty
      expect(invalid_service.errors[:lon]).not_to be_empty
    end
  end

  describe '#build_uri' do
    it 'builds URI with lat/lon' do
      service = described_class.new(lat: lat, lon: lon)
      service.valid?
      uri = service.send(:build_uri)
      expect(uri.to_s).to include("lat=#{lat}")
      expect(uri.to_s).to include("lon=#{lon}")
      expect(uri.to_s).to include('appid=')
      expect(uri.to_s).to include('units=imperial')
    end
  end
end
