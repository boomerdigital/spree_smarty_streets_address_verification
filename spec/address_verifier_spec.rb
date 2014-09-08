require 'spec_helper'



describe AddressVerifier do
  describe ".verify(location_hash)" do
    describe "on success" do
      it 'should verify an address based upon location attributes' do
        location_hash = {
            street: "123 W 117th Street",
            city: "New York",
            state: "NY",
            zipcode: "10026"
        }
        result = AddressVerifier.verify(location_hash)
        result_hash = result.first
        components = result_hash.components
        expect(components.city_name).to match(location_hash[:city])
        expect(components.state_abbreviation).to match("NY")
        expect("#{location_hash[:street]}").to start_with(result_hash.delivery_line_1)
        expect(location_hash[:zipcode]).to match(components.zipcode)
      end
    end

    describe "on failure" do
      it 'should not verify an address if input is blank' do
        location_hash = {
            street: "",
            city: "",
            state: "",
            zipcode: ""
        }
        result = AddressVerifier.verify(location_hash)
        expect(result).to eql({})
      end
    end
  end

  describe ".verify_batch(locations_hash)" do
    describe "on success" do
      it 'should verify an address based upon location attributes' do
        locations = []
        location_hash = {
            street: "123 W 117th Street",
            city: "New York",
            state: "NY",
            zipcode: "10026"
        }
        addresses = rand(1500)
        addresses.times do |n|
          locations << location_hash
        end

        result = AddressVerifier.verify_batch(locations)
        expect(result.size).to be(addresses)
        # components = result_hash.components
        # expect(components.city_name).to match(location_hash[:city])
        # expect(components.state_abbreviation).to match("NY")
        # expect("#{location_hash[:street]}").to start_with(result_hash.delivery_line_1)
        # expect(location_hash[:zipcode]).to match(components.zipcode)
      end
    end

    describe "on failure" do
      it 'should not verify an address if input is blank' do
        result = AddressVerifier.verify_batch([])
        expect(result).to eql([])
      end
    end
  end
end
