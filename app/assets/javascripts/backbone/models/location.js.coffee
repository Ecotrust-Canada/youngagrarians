class Youngagrarians.Models.Location extends Backbone.RelationalModel
  paramRoot: 'location'
  url: '/locations'

  relations: [
    {
      type: 'HasOne'
      key: 'category'
      relatedModel: 'Youngagrarians.Models.Category'
      includeInJSON: Backbone.Model.prototype.idAttribute,
      collectionType: 'Youngagrarians.Collections.CategoriesCollection'
      reverseRelation:
        key: 'location'
        includeInJSON: '_id'
    }
  ]

  lat: =>
    return @get 'latitude'

  lng: =>
    return @get 'longitude'

  locUrl: =>
    base = $("#root_url").data('url') + "#" + '/locations/' + @id

Youngagrarians.Models.Location.setup()

class Youngagrarians.Collections.LocationsCollection extends Backbone.Collection
  model: Youngagrarians.Models.Location
  url: '/locations'

  getSubdivision: (country_code, province_code)=>
    return null unless country_code and province_code
    country = _.find Youngagrarians.Constants.COUNTRIES, (c)->
      c.code == country_code
    _.find country.subdivisions, (subdivision)->
      subdivision.code == province_code
  
  getBioregion: (country_code, province_code, bioregion)=>
    return null unless country_code and province_code and bioregion
    subdivision = @getSubdivision(country_code, province_code)
    _.find subdivision.bioregions, (region)->
      region.name == bioregion
      
  updateLocationsFromGoogleMaps: =>
    service = new google.maps.places.PlacesService($.goMap.getMap())
    @.each (loc)=>     
      return if loc.get('country_name') and loc.get('Location') == 'Location'
      request =
        location: new google.maps.LatLng(loc.lat(), loc.lng())
        radius: 20      
      service.nearbySearch request, (results, status)=>
        return unless results
        place = _.find results, (place)=>
          _.find place.types, (type)=>
            type == 'establishment'
        if place
          request = 
            reference: place.reference
          service.getDetails request, (result, status)=>
            return unless result
            city = _.find result.address_components, (ac)->
              ac = _.find ac.types, (type)->
                type == 'locality'
            province = _.find result.address_components, (ac)->
              ac = _.find ac.types, (type)->
                type == 'administrative_area_level_1'
            country = _.find result.address_components, (ac)->
              ac = _.find ac.types, (type)->
                type == 'country'
            loc.url = "/locations/#{loc.id}" 
            if province
              loc.set  
                province_name: province.long_name
                province_code: province.short_name                         
            loc.save
              city: city.long_name              
              country_name: country.long_name
              country_code: country.short_name

