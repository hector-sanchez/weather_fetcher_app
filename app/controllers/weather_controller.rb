# frozen_string_literal: true

class WeatherController < ApplicationController
  def search
    address = params[:address]
    geo_result = Geocoding::LookupService.call(address_fragment: address)

    if geo_result[:valid]
      weather_result = Weather::FetcherService.by_coordinates(latitude: geo_result[:latitude], longitude: geo_result[:longitude])

      if weather_result[:valid]
        @weather = weather_result
      else
        flash.now[:alert] = weather_result[:error] if weather_result[:error].present?
      end
    else
      flash.now[:alert] = geo_result[:error] if geo_result[:error].present?
    end

    render :show
  end

  def show
    # @weather should be set by search, or can be set here if needed
  end
end
