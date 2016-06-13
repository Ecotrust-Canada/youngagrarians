module LocationsHelper
  # ------------------------------------------------------- agriculature_options
  def agriculture_options
    ['Vegetable', 'Livestock', 'Grain', 'Seed', 'Hay & Forage', 'Orchard/Fruit', 'Mixed', 'Other']
  end
  # --------------------------------------------------- agriculture_type_options
  def agriculture_type_options
    ['Certified Organic', 'Organic', 'Conventional', 'Other' ]
  end
  # ----------------------------------------------------------------- bc_regions
  def bc_regions
    [ 'Cariboo – Upper Fraser', 'Skeena – North Coast', 'Lower Mainland - Fraser Valley',
      'Thompson - Okanagan', 'Kootenays', 'Vancouver Island', 'Northeast']
  end
  # ----------------------------------------------------------- category_options
  def category_options( location, category = nil )
    # inefficient!
    category ||= NestedCategory.find( location.primary_category_id )
    @cateogry_options_list ||= build_list( category.parent, true )
    options_for_select( @cateogry_options_list.map{ |x| [ x.parent ? format( '%s > %s', x.parent.name, x.name ) : x.name, x.id] }, category.id )
  end
  # ----------------------------------------------------------------- build_list
  def build_list( c, skip_self = false )
    kids = c.children.map{ |x| build_list( x ) }.flatten
    skip_self ? kids : [c] + kids
  end
  # ------------------------------------------------------------ display_address
  def display_address( location )
    r_val = ''.html_safe
    if @location.street_address.present?
      r_val << h( @location.street_address ) 
      r_val << tag( 'br' )
    end
    if @location.city.present? && @location.province.present?
      r_val << format( '%s, %s', h( @location.city ), h( @location.province ) ).html_safe
    elsif @location.city.present?
      r_val << h( @location.city )
    elsif @location.province.present?
      r_val << h( @location.province )
    end
    if @location.postal.present?
      r_val << h( ", " + @location.postal )
    end
    r_val << tag('br' ) if @location.city.present? || @location.province.present?
    r_val << @location.country if @location.country.present?
    return r_val
  end

  # ---------------------------------------------------------- top_category_list
  def top_category_list( location )
    metas = location.nested_categories
                    .joins( "LEFT OUTER JOIN nested_categories parent ON nested_categories.parent_category_id = parent.id" )
                    .pluck( 'COALESCE( parent.name, nested_categories.name ) AS name',
                            'COALESCE( parent.id, nested_categories.id ) as x' )
    if metas.any?
      content_tag( 'ul', class: 'top_category_list' ) do 
        links = metas.map do |category_name, category_id|
          content_tag( 'li', link_to( category_name,
                             meta_category_path( top_level_name: category_name ),
                             class: "filled" ),
                          class: "category_#{category_id} #{category_name.downcase}"
                          )
        end
        safe_join( links, '' )

      end
    else
      nil
    end
  end

  # ---------------------------------------------------------- top_category_list
  def category_class_list( location )
    metas = location.nested_categories
                    .joins( "LEFT OUTER JOIN nested_categories parent ON nested_categories.parent_category_id = parent.id" )
                    .pluck( 'COALESCE( parent.name, nested_categories.name ) AS name',
                            'COALESCE( parent.id, nested_categories.id ) as x' )
    if metas.any?
      
      links = metas.map do |category_name, category_id|
        category_name.downcase
      end
      safe_join( links, ' ' )

    else
      nil
    end
  end

  # -------------------------------------------------------------- contact_links
  def contact_links( location )
    content_tag( 'div', class: 'links' ) do
      r_val = ''.html_safe
      [:url, :fb_url, :twitter_url ].each do |link_type|
        l = location.send( link_type )
        if l.present?
          r_val << link_to( l, l, class: link_type )
          r_val << tag( 'br' )
        end
      end
      r_val
    end
  end
end
