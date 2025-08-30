# frozen_string_literal: true

class WeatherController < ApplicationController
  CACHE_EXPIRATION = 30.minutes

  def search
    address = params[:address]
    return redirect_to root_path, alert: "Please enter an address" if address.blank?

    payload = fetch_weather_data(address)
    handle_weather_response(payload)
    render :show
  end

  def show
    # @weather should be set by search, or can be set here if needed
  end

  private

  def fetch_weather_data(address)
    geo_data = fetch_geocoding_data(address)
    return geo_data unless geo_data[:valid]

    weather_data = fetch_weather_by_coordinates(geo_data[:latitude], geo_data[:longitude])

    {
      geocoding: geo_data,
      weather: weather_data,
      cache_hits: determine_cache_hits(address, geo_data[:latitude], geo_data[:longitude]),
    }
  end

  def fetch_geocoding_data(address)
    cache_key = "geocoding:#{normalize_address(address)}"
    Rails.cache.fetch(cache_key, expires_in: CACHE_EXPIRATION) do
      Geocoding::LookupService.call(address_fragment: address)
    end
  end

  def fetch_weather_by_coordinates(latitude, longitude)
    cache_key = "weather:#{latitude}_#{longitude}"
    Rails.cache.fetch(cache_key, expires_in: CACHE_EXPIRATION) do
      Weather::FetcherService.by_coordinates(latitude: latitude, longitude: longitude)
    end
  end

  def determine_cache_hits(address, latitude, longitude)
    geocoding_cache_key = "geocoding:#{normalize_address(address)}"
    weather_cache_key = "weather:#{latitude}_#{longitude}"

    {
      geocoding: Rails.cache.exist?(geocoding_cache_key),
      weather: Rails.cache.exist?(weather_cache_key),
    }
  end

  def handle_weather_response(payload)
    if payload[:valid] == false
      # Handle geocoding error
      flash.now[:alert] = payload[:error] if payload[:error].present?
      return
    end

    weather_result = payload[:weather]

    if weather_result[:valid]
      @weather = weather_result
      set_cache_notice(payload[:cache_hits])
    else
      flash.now[:alert] = weather_result[:error] if weather_result[:error].present?
    end
  end

  def set_cache_notice(cache_hits)
    return unless cache_hits[:geocoding] || cache_hits[:weather]

    cache_sources = []
    cache_sources << "geocoding" if cache_hits[:geocoding]
    cache_sources << "weather data" if cache_hits[:weather]
    flash.now[:notice] = "Retrieved #{cache_sources.join(' and ')} from memory"
  end

  def normalize_address(address)
    address.to_s.downcase.strip.gsub(/\s+/, "_")
  end
end
