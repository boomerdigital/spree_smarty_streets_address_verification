class AddressGeocoding < ActiveRecord::Migration

  def up
    change_table :spree_addresses do |t|
      t.decimal :latitude, :longitude, precision: 12, scale: 9
    end

    # This is postgres specific. Perhaps we should put a check here and only
    # enable if on postgres?
    enable_extension 'cube'
    enable_extension 'earthdistance'
  end

  def down
    change_table :spree_addresses do |t|
      t.remove :latitude, :longitude
    end
  end

end
