class AddAddressFieldsToLocation < ActiveRecord::Migration
  def change
    add_column :locations, :street_address, :string
    add_column :locations, :city, :string
    add_column :locations, :country_code, :string
    add_column :locations, :country_name, :string
    add_column :locations, :province_code, :string
    add_column :locations, :province_name, :string
  end
end
