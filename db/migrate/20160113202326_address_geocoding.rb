class AddressGeocoding < ActiveRecord::Migration

  def change
    change_table :spree_addresses do |t|
      t.decimal :latitude, :longitude, precision: 12, scale: 9
    end
  end

end
