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
