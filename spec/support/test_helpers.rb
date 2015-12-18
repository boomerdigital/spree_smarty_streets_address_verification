module TestHelpers

  def fill_in_required_fields address
    address.firstname = 'John'
    address.lastname = 'Doe'
    address.phone = '555-123-4567'
  end

end
