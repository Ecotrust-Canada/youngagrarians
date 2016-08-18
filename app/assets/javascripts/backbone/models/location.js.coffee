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

  lat: => @get 'latitude'
  lng: => @get 'longitude'

  locUrl: =>
    base = "#{window.location.protocol}//#{window.location.host}/locations/#{@id}"

Youngagrarians.Models.Location.setup()

class Youngagrarians.Collections.LocationsCollection extends Backbone.Collection
  model: Youngagrarians.Models.Location
  url: '/locations'

  getSubdivision: (country, province)=>
    return null unless country and province
    country = _.find Youngagrarians.Constants.COUNTRIES, (c)->
      c.code == country
    _.find country.subdivisions, (subdivision)->
      subdivision.code == province

  getBioregion: (country, province, bioregion)=>
    return null unless country and province and bioregion
    subdivision = @getSubdivision(country, province)
    _.find subdivision.bioregions, (region)->
      region.name == bioregion

  # updateLocationsFromGoogleMaps: =>
  #   service = new google.maps.places.PlacesService($.goMap.getMap())
  #   @.each (loc)=>
  #     return if loc.get('country_name') and loc.get('Location') == 'Location'
  #     request =
  #       location: new google.maps.LatLng(loc.lat(), loc.lng())
  #       radius: 20
  #     service.nearbySearch request, (results, status)=>
  #       return unless results
  #       place = _.find results, (place)=>
  #         _.find place.types, (type)=>
  #           type == 'establishment'
  #       if place
  #         request =
  #           reference: place.reference
  #         service.getDetails request, (result, status)=>
  #           return unless result
  #           city = _.find result.address_components, (ac)->
  #             ac = _.find ac.types, (type)->
  #               type == 'locality'
  #           province = _.find result.address_components, (ac)->
  #             ac = _.find ac.types, (type)->
  #               type == 'administrative_area_level_1'
  #           country = _.find result.address_components, (ac)->
  #             ac = _.find ac.types, (type)->
  #               type == 'country'
  #           loc.url = "/locations/#{loc.id}"
  #           if province
  #             loc.set
  #               province: province.short_name
  #           loc.save
  #             city: city.long_name
  #             country: country.short_name

