class CleanUpLocations < ActiveRecord::Migration
  def change
    remove_column :locations, :province_name

    rename_column :locations, :province_code, :province

    remove_column :locations, :street_address
    rename_column :locations, :address, :street_address

    rename_column :locations, :country_code, :country
    remove_column :locations, :country_name

    Location.all.each do |location|
      address_parts = location.street_address.split(',')
      location.street_address = address_parts[0]
      location.city = address_parts[1]
      location.province = address_parts[2]

      location.save
    end
  end
end
