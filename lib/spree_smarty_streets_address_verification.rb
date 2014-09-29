require 'smartystreets'
require 'spree_core'

module SpreeSmartyStreetsAddressVerification
  mattr_accessor :enabled
  self.enabled = !Rails.env.test?
  class << self
    alias_method :enabled?, :enabled
  end
end

require 'spree_smarty_streets_address_verification/engine'

# Use fetch so system fails to boot if not configured right
SmartyStreets.set_auth \
  ENV.fetch('SMARTY_STREETS_AUTH_ID'),
  ENV.fetch('SMARTY_STREETS_AUTH_TOKEN')
