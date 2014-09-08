Spree::Address.class_eval do
  include SmartyStreetsAddressVerification

  # Indicates if an address is a valid deliverable address. Can only validate
  # addresses in the United States. If the address is outside the United States
  # then an error is thrown.
  #
  # If normalize is set to true then the normalized address returned by the
  # validation service is copied to the address attributes.
  def deliverable_address? normalize=true
    raise ActiveRecord::ActiveRecordError,
      'Cannot validate internationally' unless in_united_states?
    normalized = super street: address1, street2: address2, city: city,
      state: state_text, zipode: zipcode, addressee: company
    normalized = !!normalized unless normalize
    normalized
  end

  # Boolean to indicate if the address is in the United states
  def in_united_states?
    country.name == 'United States'
  end

  private

  # Adds an error to the address model if the address is not deliverable
  def check_address
    errors[:base] << Spree.t(:invalid_address) unless deliverable_address?
  end
  validate :check_address, if: :in_united_states?

end
