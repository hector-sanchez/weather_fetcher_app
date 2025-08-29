# frozen_string_literal: true

module Geocoding
  class LookupService
    def self.call(address_fragment:)
      result = Geocoder.search(address_fragment).first
      if result.present? && result.latitude && result.longitude
        {
          latitude: result.latitude,
          longitude: result.longitude,
          valid: true,
          error: nil,
        }
      else
        {
          valid: false,
          error: result&.data["error_message"] || "Address not found or invalid.",
        }
      end
    rescue StandardError => e
      {
        valid: false,
        error: e.message
      }
    end
  end
end
