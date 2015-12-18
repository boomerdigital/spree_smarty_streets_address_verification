class ValidatedFlag < ActiveRecord::Migration

  def change
    add_column :spree_addresses, :validated, :boolean, null: false, default: false
  end

end
