class CreateCategoryTags < ActiveRecord::Migration
  def change
    create_table :category_location_tags do |t|
      t.column :category_id, :integer, null: false
      t.column :location_id, :integer, null: false
      t.timestamps null: false
    end
  end
end
