class CreateNestedCategories < ActiveRecord::Migration
  def change
    create_table :nested_categories do |t|
      t.column :parent_category_id, :integer
      t.column :name, :string, null: false
      t.timestamps
    end
    new_categories = {}
    Category.all.each do |category|
      new_categories[category.name ] = NestedCategory.create( name: category.name )
    end
    subcategory_map = {}
    Subcategory.all.each do |subcategory|
      Rails.logger.error( "Subcateogry missing category: #{subcategory.inspect}" ) if subcategory.category.nil?
      c = new_categories[subcategory.category.name] || NestedCategory.top_level.find_by( name: subcategory.category.name )
      if c.nil?
        raise "Missing category: #{subcategory.category.name}"
      end
      subcategory_map[subcategory.id] = NestedCategory.create( name: subcategory.name,
                                                               parent_category: c )
    end
    rows = CategoryLocationTag.connection.select_rows( "SELECT location_id, subcategory_id FROM locations_subcategories" )
    rows.each do |location_id, subcategory_id|
      if subcategory_map[subcategory_id].nil?
        raise "Did not map subcategory #{subcategory_id}"
      end
      CategoryLocationTags.create( location_id: location_id,
                                   category_id: subcategory_map[subcategory_id] )
    end
  end
end
