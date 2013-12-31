class Youngagrarians.Routers.LocationsRouter extends Backbone.Router

  routes:
    "locations/:id" : "show"

  index: =>

  show: (id) =>
    locations = Youngagrarians.Collections.locations
    location = new Backbone.ModelRef locations, id
    location.bindLoadingStates
      loaded: (l) =>
        _.delay @_centerMap, 500, l

      unloaded: (l) ->
        console.log 'unloaded'

  _centerMap: (loc) =>
    Youngagrarians.Collections.results.searchById(loc.get('id'))
    _.delay (=> YA.map.currentView.openBubble(loc)), 1000
