#= require_self
#= require_tree .

@Youngagrarians =
  Models: {}
  Collections: {}
  Routers: {}
  Views: {}

@YA = new Backbone.Marionette.Application()

YA.addRegions
  map: "#map"
  sidebar: "#sidebar"
  results: "#results"

YA.addInitializer (options) ->
  data = 
    locations: new Youngagrarians.Collections.LocationsCollection()
    categories: new Youngagrarians.Collections.CategoriesCollection()
    subcategories: new Youngagrarians.Collections.SubcategoryCollection()
  
  for key, collection of data  
    collection.fetch
      reset: true

  results = new Youngagrarians.Collections.ResultsCollection
    locations: data.locations
    
  # I'm pretty sure it's something to do with backbone relational that is adding a model to my collection by default
  # but this hack clears the collection
  results.reset([])
  
  @sidebarView = new Youngagrarians.Views.Sidebar 
    data: data
    results: results
    app: @    
  @.sidebar.show @sidebarView
  
  @mapView = new Youngagrarians.Views.Map
    collection: results
  @.map.show @mapView
  
  @resultsView = new Youngagrarians.Views.Results
    collection: results  
  @.results.show @resultsView

  @.vent.on 'province:change', results.changeRegion
  @.vent.on 'province:change', @sidebarView.changeProvince
  @.vent.on 'bioregion:change', results.changeRegion
  @.vent.on 'category:add', results.addCategory
  @.vent.on 'category:remove', results.removeCategory  
  @.vent.on 'subcategory:add', results.addSubcategory
  @.vent.on 'subcategory:remove', results.removeSubcategory
  @.vent.on 'search', results.search
  @.vent.on 'search:clear', results.clearSearch
  @.vent.on 'update:locations', data.locations.updateLocationsFromGoogleMaps

YA.addInitializer (options) ->
  router = new Youngagrarians.Routers.LocationsRouter()
  Backbone.history.start()
