FactoryGirl.define do

  factory :foreign_country, parent: :country do
    name 'Germany'
    iso3 'DEU'
    iso_name 'GERMANY'
    numcode '276'
  end

  factory :ny, parent: :state do
    name 'New York'
    abbr 'NY'
  end

  factory :valid_address, class: 'Spree::Address' do
    address1 '45 Main Street'
    address2 'Suite 850'
    city 'Brooklyn'
    association :state, factory: :ny
    zipcode '11201'
    country {|address| address.state.country}
  end

  factory :invalid_address, class: 'Spree::Address' do
    address1 '123 Foo Street'
    address2 nil
    city 'Albany'
    association :state, factory: :ny
    zipcode '11243'
    country {|address| address.state.country}
  end

  factory :blank_address, class: 'Spree::Address' do
    address1 ' '
    address2 nil
    city ' '
    association :state, factory: :ny
    zipcode ' '
    country {|address| address.state.country}
  end

  factory :foreign_address, class: 'Spree::Address' do
    address1 'Prinzessinnenstr. 20'
    address2 nil
    city 'Berlin'
    zipcode '10969'
    association :country, factory: :foreign_country
  end

end
