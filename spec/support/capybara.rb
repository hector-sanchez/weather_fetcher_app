# frozen_string_literal: true

RSpec.configure do |config|
  config.before(:each, type: :feature) do |example|
    if example.metadata[:js]
      Capybara.current_driver = Capybara.javascript_driver
    else
      Capybara.current_driver = Capybara.default_driver
    end
  end

  config.after(:each, type: :feature) do
    Capybara.reset_sessions!
    Capybara.use_default_driver
  end
end

if ENV['SHOW_BROWSER']
  puts "🌐 Running tests with VISIBLE browser window"

  Capybara.default_max_wait_time = 30

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
  require 'capybara-screenshot/rspec'

  Capybara.save_path = Rails.root.join('tmp', 'capybara')
end
