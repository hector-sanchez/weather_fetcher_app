# frozen_string_literal: true

require "rails_helper"

RSpec.describe Weather::FetcherService do
  describe ".by_coordinates" do
    let(:lat) { 37.422 }
    let(:lon) { -122.084 }
    let(:api_key) { "test_api_key" }
    let(:response_body) do
      {
        location: {
          "name" => "Mountain View",
          "region" => "California",
          "country" => "USA",
          "lat" => 37.422,
          "lon" => -122.084,
        },
        current: {
          "temp_c" => 22.0,
          "temp_f" => 71.6,
          "condition" => {
            "text" => "Sunny",
            "icon" => "//cdn.weatherapi.com/weather/64x64/day/113.png",
          },
        },
      }.to_json
    end

    before do
      allow(ENV).to receive(:[]).with("WEATHER_API_KEY").and_return(api_key)
    end

    context "when the API returns success" do
      it "returns weather data and valid is true" do
        success_response = instance_double(Net::HTTPSuccess, body: response_body)
        allow(success_response).to receive(:is_a?).with(Net::HTTPSuccess).and_return(true)
        allow(Net::HTTP).to receive(:get_response).and_return(success_response)

        result = described_class.by_coordinates(latitude: lat, longitude: lon)
        expect(result[:valid]).to eq(true)
        expect(result[:location][:name]).to eq("Mountain View")
        expect(result[:location][:region]).to eq("California")
        expect(result[:location][:country]).to eq("USA")
        expect(result[:location][:latitude]).to eq(37.422)
        expect(result[:location][:longitude]).to eq(-122.084)
        expect(result[:current_condition][:text]).to eq("Sunny")
        expect(result[:current_condition][:icon]).to eq("//cdn.weatherapi.com/weather/64x64/day/113.png")
        expect(result[:current_condition][:celcius]).to eq(22.0)
        expect(result[:current_condition][:farenheit]).to eq(71.6)
        expect(result[:error]).to be_nil
      end
    end

    context "when the API returns an error response" do
      it "returns valid as false and the error body" do
        error_response = instance_double(Net::HTTPResponse, body: "API error")
        allow(error_response).to receive(:is_a?).with(Net::HTTPSuccess).and_return(false)
        allow(Net::HTTP).to receive(:get_response).and_return(error_response)

        result = described_class.by_coordinates(latitude: lat, longitude: lon)
        expect(result[:valid]).to eq(false)
        expect(result[:error]).to eq("No location found")
      end
    end

    context "when WEATHER_API_KEY is missing" do
      it "returns valid as false and a missing key error" do
        allow(ENV).to receive(:[]).with("WEATHER_API_KEY").and_return(nil)
        result = described_class.by_coordinates(latitude: lat, longitude: lon)
        expect(result[:valid]).to eq(false)
        expect(result[:error]).to eq("Missing WEATHER_API_KEY")
      end
    end

    context "when an exception occurs" do
      it "returns valid as false and the exception message" do
        allow(Net::HTTP).to receive(:get_response).and_raise(StandardError.new("Network error"))
        result = described_class.by_coordinates(latitude: lat, longitude: lon)
        expect(result[:valid]).to eq(false)
        expect(result[:error]).to eq("Network error")
      end
    end
  end
end
