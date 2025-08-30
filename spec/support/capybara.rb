# frozen_string_literal: true

# Support file for Capybara and Selenium configuration
# This file contains shared configuration for browser testing

RSpec.configure do |config|
  # Use the default rack_test driver for most tests (faster)
  # Only use the javascript driver when tests are tagged with js: true
  config.before(:each, type: :feature) do |example|
    if example.metadata[:js]
      Capybara.current_driver = Capybara.javascript_driver
    else
      Capybara.current_driver = Capybara.default_driver
    end
  end

  # Clean up after each test
  config.after(:each, type: :feature) do
    Capybara.reset_sessions!
    Capybara.use_default_driver
  end
end

# Additional Capybara configuration for debugging
if ENV['SHOW_BROWSER']
  puts "🌐 Running tests with VISIBLE browser window"

  # Increase wait time when debugging visually
  Capybara.default_max_wait_time = 30

  # Add a pause after each step for visual debugging
  RSpec.configure do |config|
    config.after(:each, type: :feature, js: true) do
      if ENV['PAUSE_AFTER_STEPS']
        puts "⏸️  Test completed. Browser will remain open for #{ENV['PAUSE_AFTER_STEPS']} seconds..."
        sleep ENV['PAUSE_AFTER_STEPS'].to_i
      end
    end
  end
end

if ENV['CAPYBARA_DEBUG']
  # Enable screenshots on failure
  require 'capybara-screenshot/rspec'

  # Keep browser open on failure for debugging
  Capybara.save_path = Rails.root.join('tmp', 'capybara')
end
