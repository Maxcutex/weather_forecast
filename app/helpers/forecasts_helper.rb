# frozen_string_literal: true

# ForecastsHelper: View helpers for weather forecast views
module ForecastsHelper
  # Renders the weather forecast details block
  def render_weather_details(weather)
    return ''.html_safe if weather.blank?

    content_tag(:div) do
      safe_join([
        weather_location_row(weather),
        weather_row('Temperature:', weather.dig('main', 'temp'), unit: '°F'),
        weather_row('Feels Like:', weather.dig('main', 'feels_like'), unit: '°F'),
        weather_row('Temp High:', weather.dig('main', 'temp_max'), unit: '°F'),
        weather_row('Temp Low:', weather.dig('main', 'temp_min'), unit: '°F'),
        weather_condition_row(weather),
        weather_row('Humidity:', weather.dig('main', 'humidity'), unit: '%'),
        weather_row('Wind:', weather.dig('wind', 'speed'), unit: 'mph'),
      ].compact)
    end
  end

  # Renders geocoding info
  def render_geocoding_info(address, coordinates, zip_code, location)
    safe_join([
      geocoding_address_row(address),
      geocoding_coordinates_row(coordinates),
      geocoding_zip_row(zip_code),
      geocoding_location_row(location),
    ].compact)
  end

  private

  # @return [String] weather row HTML
  def weather_row(label, value, unit: nil)
    return if value.blank?

    content_tag(:div, class: 'weather-results-row') do
      content_tag(:span, label, class: 'weather-results-label') +
        content_tag(:span, "#{value}#{unit}", class: 'weather-results-value')
    end
  end

  def weather_location_row(weather)
    return if weather['name'].blank?

    val = weather['name'].to_s
    val += " (#{weather['sys']['country']})" if weather.dig('sys', 'country')
    weather_row('Location:', val)
  end

  def weather_condition_row(weather)
    return unless weather['weather']&.first

    desc = weather['weather'].first['description'].capitalize
    icon = weather['weather'].first['icon']
    icon_tag = weather_icon_tag(icon)
    content_tag(:div, class: 'weather-results-row') do
      content_tag(:span, 'Condition:', class: 'weather-results-label') +
        content_tag(:span, safe_join([desc, icon_tag], ' '), class: 'weather-results-value')
    end
  end

  def weather_icon_tag(icon)
    return '' if icon.blank?

    image_tag(
      "https://openweathermap.org/img/wn/#{icon}@2x.png",
      alt: 'icon',
      style: 'vertical-align:middle;width:48px;height:48px;'
    )
  end

  def geocoding_address_row(address)
    return if address.blank?

    content_tag(:div, class: 'weather-results-row') do
      content_tag(:span, 'Address:', class: 'weather-results-label') +
        content_tag(:span, address, class: 'weather-results-value')
    end
  end

  def geocoding_coordinates_row(coordinates)
    return if coordinates.blank?

    content_tag(:div, class: 'weather-results-row') do
      content_tag(:span, 'Coordinates:', class: 'weather-results-label') +
        content_tag(:span, coordinates&.join(', '), class: 'weather-results-value')
    end
  end

  def geocoding_zip_row(zip_code)
    return if zip_code.blank?

    content_tag(:div, class: 'weather-results-row') do
      content_tag(:span, 'Zip Code:', class: 'weather-results-label') +
        content_tag(:span, zip_code, class: 'weather-results-value')
    end
  end

  def geocoding_location_row(location)
    return if location.blank?

    content_tag(:div, class: 'weather-results-row') do
      content_tag(:span, 'Full Location:', class: 'weather-results-label') +
        content_tag(:span, location&.address, class: 'weather-results-value')
    end
  end
end
