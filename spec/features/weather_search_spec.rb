# frozen_string_literal: true

require 'rails_helper'

RSpec.feature "Weather Search", type: :feature, js: true do
  before do
    # Clear cache before each test to ensure clean state
    Rails.cache.clear

    # Stub ENV calls more broadly to avoid conflicts
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with("GOOGLE_GEOCODING_API_KEY").and_return("test_google_key")
    allow(ENV).to receive(:[]).with("WEATHER_API_KEY").and_return("test_weather_key")
  end

  scenario "User searches for weather by address" do
    # Mock geocoding service response
    geocoding_response = {
      latitude: 40.8845222,
      longitude: -74.00798209999999,
      valid: true,
      error: nil,
    }
    allow(Geocoding::LookupService).to receive(:call).and_return(geocoding_response)

    # Mock weather service response
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

    # Visit the weather page
    visit root_path

    # Verify the page loads correctly
    expect(page).to have_content("Wanna get the weather for your town?")
    expect(page).to have_field("address")
    expect(page).to have_button("Search")

    # Fill in the search form
    fill_in "address", with: "Teaneck, NJ"
    click_button "Search"

    # Verify the weather results are displayed
    expect(page).to have_content("Weather for Teaneck, New Jersey, United States of America")
    expect(page).to have_content("Temperatures: 22.0°C / 71.6°F")
    expect(page).to have_content("Conditions: Partly cloudy")

    # Verify the weather icon is displayed
    expect(page).to have_css("img[alt='Partly cloudy']")
  end

  scenario "User searches with invalid address" do
    # Mock geocoding service to return an error
    geocoding_response = {
      latitude: nil,
      longitude: nil,
      valid: false,
      error: "No results found for the given address",
    }
    allow(Geocoding::LookupService).to receive(:call).and_return(geocoding_response)

    # Visit the weather page
    visit root_path

    # Fill in the search form with invalid address
    fill_in "address", with: "Invalid Address 123456"
    click_button "Search"

    # Verify error message is displayed
    expect(page).to have_content("No results found for the given address")
    expect(page).not_to have_content("Weather for")
  end

  scenario "User searches without entering an address" do
    # Visit the weather page
    visit root_path

    # Click search without entering anything
    click_button "Search"

    # Verify error message is displayed (redirect with alert)
    expect(page).to have_content("Please enter an address")
    expect(page).not_to have_content("Weather for")
  end

  # NOTE: Caching behavior can be verified manually in the browser
  # Search for the same address twice and observe the flash notice
end
