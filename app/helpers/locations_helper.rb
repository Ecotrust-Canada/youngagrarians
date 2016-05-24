module LocationsHelper
  # ----------------------------------------------------------- category_options
  def category_options( location )
    # assumes 2 levels deep.
    c = NestedCategory.level_2.order( 'parent_name, nested_categories.name' ).map do |category|
      if category.parent_name
        [format( '%s > %s', category.parent_name, category.name), category.id]
      else
        [category.name, category.id]
      end
    end
    options_for_select( c, location.nested_category_ids.first )
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
      r_val << h( @location.postal )
      r_val << tag( 'br' )
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
                             class: "category_#{category_id}" ) )
        end
        safe_join( links, '' )

      end
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
