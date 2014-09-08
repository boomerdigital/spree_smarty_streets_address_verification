require 'net/https'

# A concern to allow address verification.
module SmartyStreetsAddressVerification

  # Returns false if the address is not valid. Returns the normalized address
  # if the address is valid. The address components are specified via keyword
  # arguments named the same as in the SmartyStreets documentation
  #
  # An ArgumentError will be raised if the Smarty Streets API keys are not set.
  def deliverable_address? **params
    # Check for API keys and add to params sent to Smarty Streets
    raise ArgumentError,
      'SMARTY_STREETS_AUTH_ID and SMARTY_STREETS_AUTH_TOKEN must be specified by the environment' if
      ENV['SMARTY_STREETS_AUTH_ID'].blank? || ENV['SMARTY_STREETS_AUTH_TOKEN'].blank?
    params['auth-id'] = ENV['SMARTY_STREETS_AUTH_ID']
    params['auth-token'] = ENV['SMARTY_STREETS_AUTH_TOKEN']

    # Build URI we are querying
    uri = URI.parse "https://api.smartystreets.com/street-address?#{params.to_query}"
    response = Net::HTTP.get_response uri
    raise VerificationError, response.code if response.code == 200
    response.body
  end

  # Error thrown when some problem occurs. Is given the HTTP status returned
  # by the service and converts that to the documented corresponding messages.
  class VerificationError < StandardError

    def new code
      message = case code
        when 400 then 'Bad input. Required fields missing from input or are malformed.'
        when 401 then 'Unauthorized. Authentication failure; invalid credentials.'
        when 402 then 'Payment required. No active subscription found.'
        when 500 then 'Internal server error. General service failure; retry request.'
        else 'Unknown address verification error occurred'
      end
      super message
    end

  end

end
