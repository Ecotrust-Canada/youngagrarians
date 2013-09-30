class Youngagrarians.Models.Location extends Backbone.RelationalModel
  paramRoot: 'location'
  url: '/~youngagr/map/locations'

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
  url: '/~youngagr/map/locations'

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
            loc.url = "/~youngagr/map/locations/#{loc.id}" 
            if province
              loc.set  
                province_name: province.long_name
                province_code: province.short_name                         
            loc.save
              city: city.long_name              
              country_name: country.long_name
              country_code: country.short_name

class Youngagrarians.Constants
  
  
  @DEFAULT_BOUNDS = ->
    bounds = new google.maps.LatLngBounds()
    bounds.extend new google.maps.LatLng(49.000000, -114.072418)
    bounds.extend new google.maps.LatLng(60.001615, -139.062195)
    bounds
  
  @COUNTRIES:[{
    name: "Canada"
    code: "CAN"
    subdivision_name: "Province"
    subdivisions: [{
      name: "British Columbia"
      code: "BC"
      bounds: 
        north: 60.001615
        south: 49.000000
        east: -114.072418
        west: -139.062195
      bioregions:[{
        name: "Northeast"
        center: 
          latitude: 57.996455        
          longitude: -123.442383
        zoom: 6
      },{
        name: "Skeena-North Coast"
        center: 
          latitude: 56.096556        
          longitude: -130.517578
        zoom: 6
      },{
        name: "Vancouver Island-Coast"
        center: 
          latitude: 49.75288    
          longitude: -126.079102
        zoom: 7
      },{
        name: "Cariboo-Prince George"
        center: 
          latitude: 52.816043        
          longitude: -121.179199
        zoom: 7
      },{
        name: "Thompson-Okanagan"
        center: 
          latitude: 50.625073        
          longitude: -118.520508
        zoom: 8
      },{
        name: "Lower Mainland"
        center: 
          latitude: 49.239121        
          longitude: -122.629395
        zoom: 8
      },{
        name: "Kootenays"
        center: 
          latitude: 49.582226        
          longitude: -116.608887
        zoom: 8
      }]
    },{
      name: "Alberta"
      code: "AB"
      bounds: {
        north: 60.001615
        south: 49.000000
        east: -110.00473
        west: -119.707031
      }
      bioregions:[]
    },{
      name: "Saskatchewan"
      code: "SK"
      bounds: {
        north: 60.001615
        south: 49.000000
        east: -101.359863
        west: -110.00473
      }
      bioregions:[]
    },{
      name: "Manitoba"
      code: "MB"
      bounds: {
        north: 60.001615
        south: 49.000000
        east: -101.359863
        west: -88.9151
      }
      bioregions:[]
    },{
      name: "Ontario"
      code: "ON"
      bounds: {
        north: 56.927742
        south: 45.006079
        east: -74.135742
        west: -95.383301
      }
      bioregions:[]
    },{
      name: "Quebec"
      code: "QC"
      bounds: {
        north: 62.731141
        south: 45.052666
        east: -57.019043
        west: -79.431152
      }
      bioregions:[]
    },{
      name: "New Brunswick"
      code: "NB"
      bounds: {
        north: 46.240949
        south: 45.989627
        east: -64.033813
        west: -69.054565
      }
      bioregions:[]
    },{
      name: "Nova Scotia"
      code: "NS"
      bounds: {
        north: 47.077896
        south: 43.4293
        east: -59.61319
        west: -66.468658
      }
      bioregions:[]
    },{
      name: "Prince Edward Island"
      code: "PEI"
      bounds: {
        north: 47.062931
        south: 45.943809
        east: -61.997223
        west: -64.524078
      }
      bioregions:[]
    },{
      name: "Nunavut"
      code: "NV"
      bounds: {
        north: 73.513791
        south: 61.87331
        east: -62.20459
        west: -109.841309
      }
      bioregions:[]
    },{
      name: "Northwest Territories"
      code: "NT"
      bounds: {
        north: 70.56629
        south: 60.180453
        east: -101.835022
        west: -136.450195
      }
      bioregions:[]
    },{
      name: "Yukon"
      code: "YK"
      bounds: {
        north: 69.761144
        south: 60.045529
        east: -123.769226
        west: -141.196289
      }
      bioregions:[]
    },{
      name: "Newfoundland"
      code: "NF"
      bounds: {
        north: 60.475157
        south: 46.702496
        east: -52.483063
        west: -67.82959
      }
      bioregions:[]
    }]
  },{
    name: "United States"
    code: "USA"
    subdivision_name: "State"
    subdivisions: [{
      name: "Oregon"
      code: "OR"
      bounds: {
        north: 46.348113
        south: 42.001601
        east: -117.022247
        west: -124.141388
      }
      bioregions:[]
    }]
  }]       
           