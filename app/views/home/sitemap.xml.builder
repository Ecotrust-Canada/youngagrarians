xml.urlset( xmlns: 'http://www.sitemaps.org/schemas/sitemap/0.9' ) do
  xml.url do
    xml.loc map_url
  end
  NestedCategory.top_level.find_each do |category|
    xml.url do
      xml.loc top_level_category_url( top_level_name: category.name.downcase )
      xml.lastmod category.updated_at.to_date
    end
    category.children.each do |child|
      xml.url do
        xml.loc subcategory_url( top_level_name: category.name.downcase, subcategory_name: child.name.downcase )
        xml.lastmod category.updated_at.to_date
      end
    end
  end
  Location.find_each do |location|
    xml.url do
      xml.loc location_url( location )
      xml.lastmod location.updated_at.to_date
    end
  end
end
