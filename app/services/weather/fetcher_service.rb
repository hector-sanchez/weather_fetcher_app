# frozen_string_literal: true

require "net/http"
require "uri"
require "json"

module Weather
  class FetcherService
    BASE_URL = "https://api.weatherapi.com/v1/current.json"

    def self.by_coordinates(latitude:, longitude:)
      api_key = ENV["WEATHER_API_KEY"]
      return { valid: false, error: "Missing WEATHER_API_KEY" } if api_key.blank?

      uri = URI(BASE_URL)
      uri.query = URI.encode_www_form({ key: api_key, q: "#{latitude},#{longitude}" })

      response = Net::HTTP.get_response(uri)
      if response.is_a?(Net::HTTPSuccess)
        data = JSON.parse(response.body)
        {
          valid: true,
          location: {
            name: data["location"]["name"],
            region: data["location"]["region"],
            country: data["location"]["country"],
            latitude: data["location"]["lat"],
            longitude: data["location"]["lon"],
          },
          current_condition: {
            text: data["current"]["condition"]["text"],
            icon: data["current"]["condition"]["icon"],
            celcius: data["current"]["temp_c"],
            farenheit: data["current"]["temp_f"],
          },
          error: nil,
        }
      else
        {
          valid: false,
          error: "No location found",
        }
      end
    rescue StandardError => e
      {
        valid: false,
        error: e.message,
      }
    end
  end
end
