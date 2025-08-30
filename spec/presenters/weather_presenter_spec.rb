# frozen_string_literal: true

require "rails_helper"

RSpec.describe WeatherPresenter do
  describe "with valid weather data" do
    let(:valid_data) do
      {
        valid: true,
        location: {
          name: "New York",
          region: "New York",
          country: "United States of America",
          latitude: 40.7128,
          longitude: -74.0060,
        },
        current_condition: {
          text: "Partly cloudy",
          icon: "//cdn.weatherapi.com/weather/64x64/day/116.png",
          celcius: 22.0,
          farenheit: 71.6,
        },
        error: nil,
      }
    end

    subject(:presenter) { described_class.new(valid_data) }

    it "is valid" do
      expect(presenter).to be_valid
      expect(presenter).not_to be_invalid
    end

    describe "location methods" do
      it "exposes location data" do
        expect(presenter.location_name).to eq("New York")
        expect(presenter.location_region).to eq("New York")
        expect(presenter.location_country).to eq("United States of America")
        expect(presenter.location_latitude).to eq(40.7128)
        expect(presenter.location_longitude).to eq(-74.0060)
      end

      it "provides full location name" do
        expect(presenter.full_location_name).to eq("New York, New York, United States of America")
      end
    end

    describe "weather condition methods" do
      it "exposes condition data" do
        expect(presenter.condition_text).to eq("Partly cloudy")
        expect(presenter.condition_icon).to eq("//cdn.weatherapi.com/weather/64x64/day/116.png")
      end

      it "provides condition icon URL" do
        expect(presenter.condition_icon_url).to eq("https://cdn.weatherapi.com/weather/64x64/day/116.png")
      end

      it "exposes temperature data" do
        expect(presenter.temperature_celsius).to eq(22.0)
        expect(presenter.temperature_fahrenheit).to eq(71.6)
      end

      it "provides temperature display" do
        expect(presenter.temperature_display).to eq("22.0°C / 71.6°F")
      end
    end

    it "provides string representation" do
      expected = "New York, New York, United States of America: Partly cloudy, 22.0°C / 71.6°F"
      expect(presenter.to_s).to eq(expected)
    end

    it "has no error" do
      expect(presenter.error).to be_nil
    end
  end

  describe "with invalid weather data" do
    let(:invalid_data) do
      {
        valid: false,
        error: "No location found",
      }
    end

    subject(:presenter) { described_class.new(invalid_data) }

    it "is invalid" do
      expect(presenter).not_to be_valid
      expect(presenter).to be_invalid
    end

    it "exposes error message" do
      expect(presenter.error).to eq("No location found")
    end

    it "returns nil for location methods" do
      expect(presenter.location_name).to be_nil
      expect(presenter.location_region).to be_nil
      expect(presenter.location_country).to be_nil
      expect(presenter.full_location_name).to be_nil
    end

    it "returns nil for condition methods" do
      expect(presenter.condition_text).to be_nil
      expect(presenter.condition_icon).to be_nil
      expect(presenter.condition_icon_url).to be_nil
      expect(presenter.temperature_display).to be_nil
    end

    it "returns error message as string representation" do
      expect(presenter.to_s).to eq("No location found")
    end
  end

  describe "with nil data" do
    subject(:presenter) { described_class.new(nil) }

    it "is invalid" do
      expect(presenter).not_to be_valid
      expect(presenter).to be_invalid
    end

    it "has nil attributes" do
      expect(presenter.error).to be_nil
      expect(presenter.location_name).to be_nil
      expect(presenter.condition_text).to be_nil
      expect(presenter.temperature_display).to be_nil
    end
  end

  describe "with missing icon data" do
    let(:data_without_icon) do
      {
        valid: true,
        location: { name: "Test" },
        current_condition: { text: "Sunny" },
      }
    end

    subject(:presenter) { described_class.new(data_without_icon) }

    it "returns nil for icon URL when icon is missing" do
      expect(presenter.condition_icon_url).to be_nil
    end
  end
end
