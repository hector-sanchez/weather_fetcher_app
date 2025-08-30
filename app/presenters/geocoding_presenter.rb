# frozen_string_literal: true

class GeocodingPresenter
  attr_reader :latitude, :longitude, :error

  def initialize(geocoding_data)
    @data = geocoding_data || {}
    @latitude = @data[:latitude]
    @longitude = @data[:longitude]
    @error = @data[:error]
  end

  def valid?
    @data[:valid] == true
  end

  def invalid?
    !valid?
  end

  def coordinates
    return nil unless valid?

    [ latitude, longitude ]
  end

  def to_s
    return error if invalid?

    "#{latitude}, #{longitude}"
  end
end
