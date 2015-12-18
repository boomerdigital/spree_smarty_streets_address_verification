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
require 'spree_smarty_streets_address_verification/factories'
require 'support/test_helpers'
require 'webmock/rspec'
require 'vcr'
require 'byebug'

VCR.configure do |config|
  config.cassette_library_dir = "fixtures/vcr_cassettes"
  config.hook_into :webmock
end

# By default address validation is not enabled in tests to simplify tests
# and avoid usage limits. But for our own tests we want them enabled.
SpreeSmartyStreetsAddressVerification.enabled = true

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
  config.include TestHelpers
  config.infer_spec_type_from_file_location!
  config.mock_with :rspec
  config.color = true
  config.use_transactional_fixtures = true
  config.fail_fast = ENV['FAIL_FAST'] || false
  config.order = "random"
end
