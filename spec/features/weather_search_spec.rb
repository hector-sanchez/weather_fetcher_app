# frozen_string_literal: true

require 'rails_helper'

RSpec.feature "Weather Search", type: :feature, js: true do
  before do
    # Clear cache before each test to ensure clean state
    Rails.cache.clear
  end

  scenario "User searches for weather by address" do
    geocoding_response = {
      latitude: 40.8845222,
      longitude: -74.00798209999999,
      valid: true,
      error: nil,
    }
    allow(Geocoding::LookupService).to receive(:call).and_return(geocoding_response)

    weather_response = {
      valid: true,
      location: {
        name: "Teaneck",
        region: "New Jersey",
        country: "United States of America",
        latitude: 40.898,
        longitude: -74.016,
      },
      current_condition: {
        text: "Partly cloudy",
        icon: "//cdn.weatherapi.com/weather/64x64/day/116.png",
        celcius: 22.0,
        farenheit: 71.6,
      },
      error: nil,
    }
    allow(Weather::FetcherService).to receive(:by_coordinates).and_return(weather_response)

    visit root_path

    expect(page).to have_content("Wanna get the weather for your town?")
    expect(page).to have_field("address")
    expect(page).to have_button("Search")

    fill_in "address", with: "Teaneck, NJ"
    click_button "Search"

    expect(page).to have_content("Weather for Teaneck, New Jersey, United States of America")
    expect(page).to have_content("Temperatures: 22.0°C / 71.6°F")
    expect(page).to have_content("Conditions: Partly cloudy")
    expect(page).to have_css("img[alt='Partly cloudy']")
  end

  scenario "User searches with invalid address" do
    geocoding_response = {
      latitude: nil,
      longitude: nil,
      valid: false,
      error: "No results found for the given address",
    }
    allow(Geocoding::LookupService).to receive(:call).and_return(geocoding_response)

    visit root_path

    fill_in "address", with: "Invalid Address 123456"
    click_button "Search"

    expect(page).to have_content("No results found for the given address")
    expect(page).not_to have_content("Weather for")
  end

  scenario "User searches without entering an address" do
    visit root_path

    click_button "Search"

    expect(page).to have_content("Please enter an address")
    expect(page).not_to have_content("Weather for")
  end
end
