Spree::Address.class_eval do

  # If an address has been verified then the long/lat is captured. This provides
  # a scope where you can get all addresses near the given lat/lng with a max
  # distance of the given amount (optional).
  #
  # This is postgres specific. Perhaps we should put a check here and only
  # define if on postgres?
  #
  # ** NOTE: postgres earthdistance orders points as (lng,lat) **
  scope :by_distance_from_latlong, -> (lat, lng, max_distance = nil) {
    target   = "point(#{lng}, #{lat})"
    destination  = "point(#{table_name}.longitude, #{table_name}.latitude)"
    miles_apart = "(#{target} <@> #{destination})"

    query = select("#{miles_apart} as miles").where.not latitude: nil, longitude: nil
    query = query.where("#{miles_apart} <= ?", max_distance) if max_distance.present?
    query
  }

  # Indicates if an address is a valid deliverable address. Can only validate
  # addresses in the United States. If the address is outside the United States
  # then an error is thrown.
  def deliverable_address?
    raise SpreeSmartyStreetsAddressVerification::UnsupportedAddress,
      'Cannot validate internationally' unless in_united_states?

    # Grab out the fields we need and wrap up in object
    address = SmartyStreets::StreetAddressRequest.new \
      street: address1.to_s, street2: address2.to_s, city: city.to_s,
      state: state_text.to_s, zipcode: zipcode.to_s, addressee: company.to_s

    begin
      address = SmartyStreets::StreetAddressApi.call address

      if address.empty?
        # The API returns a list of address since it can validate multiple
        # addresses at once. If the list is empty then the address did not
        # validate so just return false
        return false
      else
        # If the list is not empty grab the first one and normalize the address
        # fields so the normalized version is saved.
        address = address.first
        self.company = address.addressee
        self.address1 = combine %i(
          primary_number street_predirection street_name
          street_suffix street_postdirection
        ), address
        self.address2 = combine %i(secondary_designator secondary_number), address
        self.city = address.components.city_name
        self.state = country.states.find_by abbr: address.components.state_abbreviation
        self.zipcode = combine %i(zipcode plus4_code), address, '-'

        # Also store the long/lat. It's useful and SmartyStreets provides it
        self.latitude = address.metadata.latitude
        self.longitude = address.metadata.longitude

        return true
      end
    rescue SmartyStreets::ApiError
      if $!.code == SmartyStreets::ApiError::BAD_INPUT
        # If address did not have required fields then treat as a
        # non-deliverable address.
        return false
      else
        # All other errors are configuration and availability issues that
        # should raise an exception so the ops team can respond
        raise
      end
    end
  end

  # Boolean to indicate if the address is in the United states
  def in_united_states?
    # Use iso_name since the Spree factory uses "United States of America" for
    # the name while the spree seed data uses "United States". It's possible
    # a store may even customize the name to something else. So iso_name
    # seems safer. Use `try` in case country is not set.
    country.try(:iso_name) == 'UNITED STATES'
  end

  private

  def automatically_validate_address?
    return false unless migrated_for_validation?
    return false unless in_united_states?
    return false unless SpreeSmartyStreetsAddressVerification.enabled? self
    return true if address_validation_field_changed?
    not validated?
  end

  def address_validation_field_changed?
    return false unless migrated_for_validation?
    return false if new_record? && validated?
    return true if new_record?
    (changed & %w(address1 address2 city zipcode company state_name)).any? ||
    (state.id != state_id_was) || (country.id != country_id_was)
  end

  # Adds an error to the address model if the address is not deliverable
  def check_address
    return unless migrated_for_validation?
    self.validated = deliverable_address?
    errors[:base] << Spree.t(:invalid_address) unless validated?
  end
  validate :check_address, if: :automatically_validate_address?

  def combine components, address, sep=' '
    components.collect do |method|
      address.components.public_send method
    end.reject(&:blank?) * sep
  end

  # The `validated` field was added later. If the application:
  #
  # * Updates to the version of this plugin with the field
  # * Hasn't yet run the migration
  # * Is runnign code that saves addresses (for example an earlier migration)
  #
  # Then we get an error. This prevents that error by skipping validation until
  # the data model is ready.
  #
  # OK to remove this down the road once we feel there is not reasonble chance
  # somebody using the plugin has not run the migration.
  def migrated_for_validation?
    respond_to? :validated?
  end

end
