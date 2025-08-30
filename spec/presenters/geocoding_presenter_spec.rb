# frozen_string_literal: true

require "rails_helper"

RSpec.describe GeocodingPresenter do
  describe "with valid geocoding data" do
    let(:valid_data) do
      {
        latitude: 40.7128,
        longitude: -74.0060,
        valid: true,
        error: nil,
      }
    end

    subject(:presenter) { described_class.new(valid_data) }

    it "is valid" do
      expect(presenter).to be_valid
      expect(presenter).not_to be_invalid
    end

    it "exposes latitude and longitude" do
      expect(presenter.latitude).to eq(40.7128)
      expect(presenter.longitude).to eq(-74.0060)
    end

    it "returns coordinates as an array" do
      expect(presenter.coordinates).to eq([ 40.7128, -74.0060 ])
    end

    it "returns formatted string representation" do
      expect(presenter.to_s).to eq("40.7128, -74.006")
    end

    it "has no error" do
      expect(presenter.error).to be_nil
    end
  end

  describe "with invalid geocoding data" do
    let(:invalid_data) do
      {
        valid: false,
        error: "Address not found or invalid.",
      }
    end

    subject(:presenter) { described_class.new(invalid_data) }

    it "is invalid" do
      expect(presenter).not_to be_valid
      expect(presenter).to be_invalid
    end

    it "exposes error message" do
      expect(presenter.error).to eq("Address not found or invalid.")
    end

    it "returns nil for coordinates" do
      expect(presenter.coordinates).to be_nil
    end

    it "returns error message as string representation" do
      expect(presenter.to_s).to eq("Address not found or invalid.")
    end

    it "has nil latitude and longitude" do
      expect(presenter.latitude).to be_nil
      expect(presenter.longitude).to be_nil
    end
  end

  describe "with nil data" do
    subject(:presenter) { described_class.new(nil) }

    it "is invalid" do
      expect(presenter).not_to be_valid
      expect(presenter).to be_invalid
    end

    it "has nil attributes" do
      expect(presenter.latitude).to be_nil
      expect(presenter.longitude).to be_nil
      expect(presenter.error).to be_nil
      expect(presenter.coordinates).to be_nil
    end
  end
end
