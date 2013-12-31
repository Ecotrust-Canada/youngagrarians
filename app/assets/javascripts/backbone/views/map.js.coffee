class Youngagrarians.Views.Map extends Backbone.Marionette.CompositeView
  template: "backbone/templates/map"
  itemView: Youngagrarians.Views.MapMarker
  map: null

  collectionEvents:
    'reset' : 'updateMap'

  initialize: (options) =>
    @app = options.app
    @markers = []

  updateMap: =>
    window.infoBubble.close() if window.infoBubble
    $.goMap.clearMarkers()

    if @collection.currentBioregion
      @map.setCenter new google.maps.LatLng(@collection.currentBioregion.center.latitude, @collection.currentBioregion.center.longitude)
      @map.setZoom @collection.currentBioregion.zoom
    else if @collection.currentSubdivision
      bounds = new google.maps.LatLngBounds()
      bounds.extend new google.maps.LatLng(@collection.currentSubdivision.bounds.south, @collection.currentSubdivision.bounds.east)
      bounds.extend new google.maps.LatLng(@collection.currentSubdivision.bounds.north, @collection.currentSubdivision.bounds.west)
      @map.fitBounds(bounds)
    else
      bounds = new google.maps.LatLngBounds()
      @collection.each (location)=>
        if location.lat() and location.lng()
          coords = new google.maps.LatLng(location.lat(), location.lng())
          bounds.extend coords
      if @collection.length > 0
        @map.fitBounds(bounds)
        @map.setZoom 10 if @map.getZoom() > 10
      else
        @map.fitBounds(Youngagrarians.Constants.DEFAULT_BOUNDS())
    _.defer =>
      @children.each (child) =>
        marker = child.createMarker()

  onShow: () =>
    @show = []
    @$("#map").goMap
      latitude: 54.826008
      longitude: -125.200195
      zoom: 5
      maptype: 'ROADMAP'
      scrollwheel: false

    @map = $.goMap.getMap()

  openBubble: (location) => @children.findByModel(location).openBubble()

