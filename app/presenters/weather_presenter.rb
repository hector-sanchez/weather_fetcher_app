# frozen_string_literal: true

class WeatherPresenter
  attr_reader :error

  def initialize(weather_data)
    @data = weather_data || {}
    @error = @data[:error]
  end

  def valid?
    @data[:valid] == true
  end

  def invalid?
    !valid?
  end

  # Location methods
  def location_name
    location_data[:name]
  end

  def location_region
    location_data[:region]
  end

  def location_country
    location_data[:country]
  end

  def location_latitude
    location_data[:latitude]
  end

  def location_longitude
    location_data[:longitude]
  end

  def full_location_name
    return nil unless valid?

    "#{location_name}, #{location_region}, #{location_country}"
  end

  # Weather condition methods
  def condition_text
    current_condition[:text]
  end

  def condition_icon
    current_condition[:icon]
  end

  def condition_icon_url
    return if condition_icon.blank?

    "https:#{condition_icon}"
  end

  def temperature_celsius
    current_condition[:celcius]
  end

  def temperature_fahrenheit
    current_condition[:farenheit]
  end

  def temperature_display
    return nil unless valid?

    "#{temperature_celsius}°C / #{temperature_fahrenheit}°F"
  end

  def to_s
    return error if invalid?

    "#{full_location_name}: #{condition_text}, #{temperature_display}"
  end

  private

  def location_data
    @data[:location] || {}
  end

  def current_condition
    @data[:current_condition] || {}
  end
end
