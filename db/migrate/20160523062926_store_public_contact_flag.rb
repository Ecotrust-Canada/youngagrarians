class StorePublicContactFlag < ActiveRecord::Migration
  def change
    add_column :locations, :public_contact, :boolean, null: false, default: true
  end
end
