class SpreeSmartyStreetsAddressVerification::Engine < Rails::Engine
  require 'spree/core'
  isolate_namespace Spree
  engine_name 'spree_smarty_streets_address_verification'

  # use rspec for tests
  config.generators do |g|
    g.test_framework :rspec
  end

  def self.activate
    Dir.glob(File.join(File.dirname(__FILE__), '../../app/**/*_decorator*.rb')) do |c|
      Rails.configuration.cache_classes ? require(c) : load(c)
    end
  end

  initializer 'authenticate smarty streets' do
    # Only authenticate if credentials are provided
    SmartyStreets.set_auth \
      ENV['SMARTY_STREETS_AUTH_ID'], ENV['SMARTY_STREETS_AUTH_TOKEN'] unless
      %w(ID TOKEN).any? {|k| ENV["SMARTY_STREETS_AUTH_#{k}"].nil? }
  end

  config.to_prepare &method(:activate).to_proc
end
