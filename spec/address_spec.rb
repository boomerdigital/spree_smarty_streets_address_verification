require 'spec_helper'

describe 'Spree::Address extended to validate address' do
  let(:valid_address) { build :valid_address }
  let(:foreign_address) { build :foreign_address }
  let(:invalid_address) { build :invalid_address }
  let(:blank_address) { build :blank_address }

  it 'can determine if a US address' do
    expect( valid_address.in_united_states? ).to be true
    expect( foreign_address.in_united_states? ).to be false
  end

  it 'can validate and normalize an valid address' do
    VCR.use_cassette "valid address" do
      expect( valid_address.deliverable_address? ).to be true
      expect( valid_address.address1 ).to eq '45 Main St'
      expect( valid_address.address2 ).to eq 'Ste 850'
      expect( valid_address.zipcode ).to eq '11201-8200'
    end
  end

  it 'will throw an error if validating a foreign address' do
    expect { foreign_address.deliverable_address? }.to \
      raise_error SpreeSmartyStreetsAddressVerification::UnsupportedAddress
  end

  it 'will indicate an invalid address is invalid' do
    VCR.use_cassette "invalid address" do
      expect( invalid_address.deliverable_address? ).to be false
    end
  end

  it 'will indicate an incomplete address is invalid' do
    VCR.use_cassette "blank address" do
      expect( blank_address.deliverable_address? ).to be false
    end
  end

  it 'will automatically validate an us address' do
    VCR.use_cassette "valid address" do
      fill_in_required_fields valid_address
      expect( valid_address.valid? ).to be true
      expect( valid_address.address1 ).to eq '45 Main St'
      expect( valid_address.address2 ).to eq 'Ste 850'
      expect( valid_address.zipcode ).to eq '11201-8200'
    end
  end

  it 'will not automatically validate a foreign address' do
    fill_in_required_fields foreign_address
    expect( foreign_address.valid? ).to be true
  end

  it 'will not validate if not changed' do
    VCR.use_cassette "valid address" do
      fill_in_required_fields valid_address
      valid_address.save! # This will do an initial validation
    end

    # Normally this would trigger another lookup on validation since it changed.
    valid_address.city = 'Foofople'
    valid_address.zipcode = '11111'
    expect( valid_address.changed? ).to be true

    # We are manually resetting the dirty flags so it looks like nothing
    # was changed. Confirm it thinks nothing changed and it thinks it is
    # still valid (i.e. it doesn't do another lookup).
    valid_address.instance_variable_set("@changed_attributes", nil)
    expect( valid_address.changed? ).to be false

    # Change some other field not related to lookups
    valid_address.firstname = 'Joe'
    expect( valid_address.valid? ).to be true
  end

  # There are a few errors that we wnat to bubble up as they are due to
  # availability or configuration problems. These should generate an error
  # that the ops team can resolve.
  it 'will allow smarty street errors to bubble up' do
    stub_request(:post, /^https\:\/\/api.smartystreets.com\/street\-address/).to_return status: 500
    expect{ valid_address.deliverable_address? }.to raise_error SmartyStreets::ApiError
  end

end
