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
    # Check cache hits BEFORE fetching data
    geocoding_cache_key = "geocoding:#{normalize_address(address)}"
    geocoding_cache_hit = Rails.cache.exist?(geocoding_cache_key)
    geo_data = fetch_geocoding_data(address)
    geo_presenter = GeocodingPresenter.new(geo_data)
    return geo_presenter unless geo_presenter.valid?

    # Check weather cache hit BEFORE fetching weather data
    weather_cache_key = "weather:#{geo_presenter.latitude}_#{geo_presenter.longitude}"
    weather_cache_hit = Rails.cache.exist?(weather_cache_key)
    weather_data = fetch_weather_by_coordinates(geo_presenter.latitude, geo_presenter.longitude)
    weather_presenter = WeatherPresenter.new(weather_data)

    {
      geocoding_presenter: geo_presenter,
      weather_presenter: weather_presenter,
      cache_hits: {
        geocoding: geocoding_cache_hit,
        weather: weather_cache_hit,
      },
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

  def handle_weather_response(payload)
    if payload.is_a?(GeocodingPresenter) && payload.invalid?
      # Handle geocoding error
      flash.now[:alert] = payload.error if payload.error.present?
      return
    end

    weather_presenter = payload[:weather_presenter]

    if weather_presenter.valid?
      @weather_presenter = weather_presenter
      set_cache_notice(payload[:cache_hits])
    else
      flash.now[:alert] = weather_presenter.error if weather_presenter.error.present?
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
