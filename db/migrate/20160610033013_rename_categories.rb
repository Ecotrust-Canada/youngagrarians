class RenameCategories < ActiveRecord::Migration
  CATEGORY_STRUCTURE = { 'Networking' => ['Events', 'Organizations', 'Farms' ],
                         'Education' => ['Educational Programs', 'Publications', 'Web Resources' ],
                         'Jobs & Training' => ['Apprenticeships', 'Jobs'],
                         'Business' => ['Business Development', 'Funding' ],
                         'Land' => ['Land Listings', 'Farmers Looking for Land', 'Resources'],
                         'Run Your Farm' => [ 'Markets', 'Seeds', 'Production Planning Tools', 'Services & Suppliers', 'Infrastructure'] }
  ALIASES = { "Apprenticeship" => 'Apprenticeships',
              'Event' => 'Events',
              'Farm' => 'Farms',
              'Organization' => 'Organizations',
              'Publication' => "Publications",
              'Seed' => 'Seeds',
              'Web Resource' => 'Web Resources',
              'Market' => 'Markets',
              'Job' => 'Jobs' }

  NESTING_CHANGES = { 'Farm Business Planning' => 'Business Development',
                      'Regulatory' => 'Business Development',
                      'Crop Planning' => 'Business Development',
                      'University' => 'Educational Programs',
                      'College' => 'Educational Programs',
                      'Online' => 'Educational Programs',
                      'Classroom' => 'Educational Programs',
                      'Informal Education' => 'Educational Programs',
                      'Internship' => 'Educational Programs',
                      'Bees' => 'Educational Programs',
                      'Land Access' => 'Resources',
                      'Training' => 'Business Development',
                      'Courses' => 'Educational Programs',
                      'Cooperative' => 'Land Listings' }
  def change
    execute( 'TRUNCATE nested_categories' )
    execute( 'TRUNCATE category_location_tags' )
    lookup = setup_categories_from_mockups
    category_id_map = check_old_categories( lookup )
    subcategory_map = check_subcategories( lookup, category_id_map )
    rows = CategoryTag.connection.select_rows( "SELECT location_id, subcategory_id FROM locations_subcategories" )
    rows.each do |location_id, subcategory_id|
      if subcategory_map[subcategory_id.to_i].nil?
        say "Did not map subcategory #{subcategory_id}"
      else
        l = Location.find_by( id: location_id.to_i )
        if l
          CategoryTag.create!( location_id: location_id.to_i,
                               category_id: subcategory_map[subcategory_id.to_i] )
        else
          say "Found invalid location: #{location_id}" 
        end
      end
    end

    # Handle locations not tied to a sub category
    Location.find_each do |location|
      is_found = false
      category = Category.find( location.category_id )
      next unless category.name.present?
      is_found = false
      location.nested_categories.each do |c|
        loop do
          if category.name == c.name
            is_found = true
            break
          end
          c = c.parent
          break if c.parent.nil?
        end
      end
      unless is_found
        missing_category_options = NestedCategory.where( name: category.name )
        if missing_category_options.length == 0
          missing_category_options = NestedCategory.where( name: ALIASES[category.name] )
        end
        if missing_category_options.length != 1
          raise "TOO MANY CATEGORIES: #{category.name} ---- #{missing_category_options.inspect}"
        end
        CategoryTag.create!( location: location,
                             nested_category: missing_category_options.first )
      end
    end
  end

  def check_subcategories( lookup, category_id_map )
    subcategory_map = {}
    bad_subs = []
    Subcategory.all.each do |subcategory|
      if subcategory.category.nil?
        Rails.logger.error( "Subcateogry missing category: #{subcategory.inspect}" ) 
      else
        next if subcategory.category.nil?
        next if subcategory.category.nil?
        next if lookup[subcategory.name] || lookup[ ALIASES[ subcategory.name ] ]
        c = if NESTING_CHANGES[ subcategory.name ]
              NestedCategory.create( parent_category_id: lookup.fetch( NESTING_CHANGES[ subcategory.name ] ),
                                     name: subcategory.name )
            else
              NestedCategory.create( parent_category_id: category_id_map.fetch( subcategory.category_id ),
                                     name: subcategory.name )
            end
        if c.parent.parent.nil?
          bad_subs.push( subcategory )
        end
        subcategory_map[ subcategory.id ] = c.id
      end
    end
    if bad_subs.any?
      raise bad_subs.map{ |x| "#{x.name} => #{x.category.name}" }.inspect
    end
    return subcategory_map
  end
  # ---------------------------------------------- setup_categories_from_mockups
  def setup_categories_from_mockups
    lookup = {}
    CATEGORY_STRUCTURE.each_pair do |k,v|
      meta = NestedCategory.create!( name: k )
      lookup[k] = meta.id
      v.each do |subcategory|
        kid = meta.children.create!( name: subcategory )
        lookup[kid.name] = kid.id
      end
    end
    return lookup
  end
  def check_old_categories( lookup )
    bad_categories = []
    category_id_map = {}
    Category.find_each do |category|
      nested_category_id = lookup[category.name] || ( ALIASES[category.name] && lookup[ ALIASES[category.name] ] )
      if nested_category_id
        category_id_map[category.id] = nested_category_id
      else
        bad_categories.push( category )
      end
    end
    if bad_categories.any?
      raise format( 'Bad categories: %s', bad_categories.map( &:name ) )
    end
    return category_id_map
  end
end
