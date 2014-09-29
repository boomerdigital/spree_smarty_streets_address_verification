# Run Coverage report
require 'simplecov'
SimpleCov.start do
  add_filter 'spec/dummy'
  add_group 'Models', 'app/models'
  add_group 'Libraries', 'lib'
end

# Configure Rails Environment
ENV['RAILS_ENV'] = 'test'
require File.expand_path('../dummy/config/environment.rb',  __FILE__)
require 'rspec/rails'
require 'spree/testing_support/factories'

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods

  # Infer an example group's spec type from the file location.
  config.infer_spec_type_from_file_location!

  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec
  config.color = true

  config.use_transactional_fixtures = true

  config.fail_fast = ENV['FAIL_FAST'] || false
  config.order = "random"
end
