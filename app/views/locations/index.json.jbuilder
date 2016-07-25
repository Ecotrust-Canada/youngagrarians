meta_lookup = NestedCategory.meta_lookup
json.array! @locations do |location|
  json.id location.id
  json.name location.name

  json.latitude location.latitude
  json.longitude location.longitude
  #json.bioregion location.bioregion
  json.city  location.city
  #json.country location.country
  json.province location.province
  json.phone location.phone
  json.email location.email
  json.street_address location.street_address
  #json.hasGoogleMap location.gmaps
  #json.postalCode location.postal

  #json.facebookUrl location.fb_url
  #json.twitterUrl location.twitter_url

  #json.content location.content
  #json.description location.description

  #json.owner nil
  
  #json.created location.created_at
  #json.updated location.updated_at

  json.url location.url
  #json.resourceType location.resource_type
  json.categories location.nested_categories do |category|
    json.id category.id
    json.name category.name
    # Primary category are children of metas
    json.meta meta_lookup[ category.id ][:meta]
    json.primary meta_lookup[ category.id ][:primary]
  end
end

