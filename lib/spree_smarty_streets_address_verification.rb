require 'smartystreets'
require 'spree_core'

module SpreeSmartyStreetsAddressVerification
  mattr_accessor :enabled
  self.enabled = !Rails.env.test?

  def self.enabled? address=nil
    # Always disabled if SmartyStreets not authenticated. Will only
    # respond to `set_auth` if not authenticated
    return false if SmartyStreets.respond_to? :set_auth

    if enabled.respond_to? :call
      enabled[address]
    else
      enabled
    end
  end

  class UnsupportedAddress < StandardError; end

end

require 'spree_smarty_streets_address_verification/engine'

# Only authenticate if credentials are provided
SmartyStreets.set_auth \
  ENV['SMARTY_STREETS_AUTH_ID'], ENV['SMARTY_STREETS_AUTH_TOKEN'] unless
  %w(ID TOKEN).any? {|k| ENV["SMARTY_STREETS_AUTH_#{k}"].nil? }
