class AddPostidToLocations < ActiveRecord::Migration
  def change
    add_column :locations, :post_id, :string
  end
end
