class CreateNestedCategories < ActiveRecord::Migration
  def change
    create_table :nested_categories do |t|
      t.column :parent_category_id, :integer
      t.column :name, :string, null: false
      t.timestamps null: false
    end
    new_categories = {}
    Category.all.each do |category|
      new_categories[category.name ] = NestedCategory.find_or_create_by( name: category.name )
    end
    subcategory_map = {}
    Subcategory.all.each do |subcategory|
      if subcategory.category.nil?
        Rails.logger.error( "Subcateogry missing category: #{subcategory.inspect}" ) 
      else
        next if subcategory.category.nil?
        next if subcategory.category.nil?
        c = new_categories[subcategory.category.name] || NestedCategory.top_level.find_by( name: subcategory.category.name )
        if c.nil?
          say "Missing category: #{subcategory.category.name}"
        end
        if subcategory.name.present?
          subcategory_map[subcategory.id.to_i] = NestedCategory.create!( name: subcategory.name,
                                                                         parent: c )
        else
          say "Subcategory mssing name: #{subcategory.category.name}"
        end
      end
    end
    rows = CategoryTag.connection.select_rows( "SELECT location_id, subcategory_id FROM locations_subcategories" )
    rows.each do |location_id, subcategory_id|
      if subcategory_map[subcategory_id.to_i].nil?
        say "Did not map subcategory #{subcategory_id}"
      else
        if l = Location.where( id: location_id.to_i ).first
          CategoryTag.create!( location_id: location_id.to_i,
                               category_id: subcategory_map[subcategory_id.to_i].id )
        else
          say "Found invalid location: #{location_id}" 
        end
      end
    end
    # Handle locatoins not tied to a sub category
    Location.find_each do |location|
      is_found = false
      category = Category.find( location.category_id )
      next unless category && category.name.present?
      location.nested_categories.each do |c|
        if c.parent && c.parent.name == category.name
          is_found = true
          break
        end
      end
      c = new_categories[category.name] || NestedCategory.top_level.find_or_create_by( name: category.name )
      unless is_found
        CategoryTag.create!( location: location,
                             nested_category: c )
      end
    end
  end
end
