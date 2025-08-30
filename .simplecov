# SimpleCov configuration file
SimpleCov.start 'rails' do
  # Project name for reports
  project_name 'Weather App'

  # Minimum coverage percentage
  minimum_coverage 85
  minimum_coverage_by_file 70

  # Refuse to merge results that are older than 10 minutes
  merge_timeout 600

  # Coverage tracking
  track_files '{app,lib}/**/*.rb'

  # Exclude files from coverage
  add_filter '/bin/'
  add_filter '/db/'
  add_filter '/spec/'
  add_filter '/test/'
  add_filter '/config/'
  add_filter '/vendor/'
  add_filter '/tmp/'
  add_filter '/log/'
  add_filter '/public/'
  add_filter '/storage/'
  add_filter 'application_record.rb'
  add_filter 'application_job.rb'
  add_filter 'application_mailer.rb'
  add_filter 'application_cable'

  # Group coverage by type
  add_group 'Controllers', 'app/controllers'
  add_group 'Models', 'app/models'
  add_group 'Services', 'app/services'
  add_group 'Presenters', 'app/presenters'
  add_group 'Helpers', 'app/helpers'
  add_group 'Jobs', 'app/jobs'
  add_group 'Mailers', 'app/mailers'
  add_group 'Libraries', 'lib'

  # Enable branch coverage (Ruby 2.5+)
  enable_coverage :branch if RUBY_VERSION >= '2.5'

  # Configure formatters based on environment
  if ENV['CI']
    # CI environment - send to Codecov
    require 'codecov'
    formatter SimpleCov::Formatter::Codecov
  else
    # Local development - HTML only
    formatter SimpleCov::Formatter::HTMLFormatter
  end
end
