class AddPost2idToLocations < ActiveRecord::Migration
  def change
    add_column :locations, :post2_id, :string
  end
end
