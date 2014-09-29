require 'smartystreets'
require 'spree_core'
require 'spree_smarty_streets_address_verification/engine'

# Use fetch so system fails to boot if not configured right
SmartyStreets.set_auth \
  ENV.fetch('SMARTY_STREETS_AUTH_ID'),
  ENV.fetch('SMARTY_STREETS_AUTH_TOKEN')
