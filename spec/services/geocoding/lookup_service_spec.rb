# frozen_string_literal: true

require "rails_helper"

RSpec.describe Geocoding::LookupService do
  describe ".call" do
    subject(:result) do
      described_class.call(address_fragment: input)
    end

    let(:valid_address) { "1600 Amphitheatre Parkway, Mountain View, CA" }
    let(:invalid_address) { "asdfghjkl" }

    context "when the address is valid" do
      let(:input) { valid_address }

      before do
        allow(Geocoder).to receive(:search).with(valid_address).and_return([
          double(latitude: 37.422, longitude: -122.084, present?: true),
        ])
      end

      it "returns latitude and longitude and valid is true" do
        expect(result[:valid]).to eq(true)
        expect(result[:latitude]).to eq(37.422)
        expect(result[:longitude]).to eq(-122.084)
        expect(result[:error]).to be_nil
      end
    end

    context "when the address is invalid" do
      let(:input) { invalid_address }

      before do
        allow(Geocoder).to receive(:search).with(invalid_address).and_return([
          double(latitude: nil, longitude: nil, present?: false, data: { "error_message" => "Invalid address" }),
        ])
      end

      it "returns valid as false and an error message" do
        expect(result[:valid]).to eq(false)
        expect(result[:error]).to eq("Invalid address")
      end
    end

    context "when an exception occurs" do
      let(:input) { valid_address }

      before do
        allow(Geocoder).to receive(:search).and_raise(StandardError.new("API error"))
      end

      it "returns valid as false and the exception message" do
        expect(result[:valid]).to eq(false)
        expect(result[:error]).to eq("API error")
      end
    end
  end
end
