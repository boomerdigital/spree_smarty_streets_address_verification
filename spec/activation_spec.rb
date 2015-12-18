require 'spec_helper'

describe 'library activation' do
  let(:invalid_address) { build :invalid_address }

  it 'will not automatically validate an address if disabled' do
    begin
      SpreeSmartyStreetsAddressVerification.enabled = false
      fill_in_required_fields invalid_address
      expect( invalid_address.valid? ).to be true
    ensure
      SpreeSmartyStreetsAddressVerification.enabled = true
    end
  end

  it 'will allow validation to be conditional' do
    begin
      SpreeSmartyStreetsAddressVerification.enabled = lambda do |address|
        address.address2.blank?
      end
      VCR.use_cassette "invalid address" do
        fill_in_required_fields invalid_address
        expect( invalid_address.valid? ).to be false
      end
      invalid_address.address2 = 'Suite 100'
      expect( invalid_address.valid? ).to be true
    ensure
      SpreeSmartyStreetsAddressVerification.enabled = true
    end
  end

  it 'will automatically disable validation if not authenticated' do
    begin
      expect( SpreeSmartyStreetsAddressVerification.enabled? ).to eq true

      # Re-define method to pertend we never authenticated
      def SmartyStreets.set_auth(*args); end

      fill_in_required_fields invalid_address
      expect( invalid_address.valid? ).to be true
    ensure
      SmartyStreets.singleton_class.send :remove_method, :set_auth
    end
  end

end
