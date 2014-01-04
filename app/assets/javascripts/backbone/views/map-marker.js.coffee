class Youngagrarians.Views.MapMarker extends Backbone.Marionette.ItemView
  template: "backbone/templates/map-marker"

  initialize: ->
    @marker = null

  createMarker: =>
    data = @model.toJSON()
    data.link = encodeURIComponent @model.locUrl()

    category = @model.get('category').get('name')
    icon = @model.get('category').getMapIcon()

    data.category_name = category
    data.category_icon = icon

    subcategories = _( @model.get('subcategories') ).pluck('name').join(' , ')
    data.subcategories = subcategories

    lat = @model.get 'latitude'
    long = @model.get 'longitude'

    if !_.isUndefined( lat ) and !_.isNull( lat ) and !_.isUndefined( long ) and !_.isNull( long )
      @marker = $.goMap.createMarker
        latitude: @model.get 'latitude'
        longitude: @model.get 'longitude'
        id: 'location-' + @model.id
        group: category
        title: @model.get 'name'
        icon: icon

      @model.marker = @marker

      @content = JST['backbone/templates/map-marker-bubble'](data)

      $.goMap.createListener(
        { type: 'marker', marker: @marker.id },
        'click',
        @openBubble
        )
    @marker

  openBubble: =>
    window.infoBubble.close() if not _.isUndefined(window.infoBubble) and not _.isNull(window.infoBubble)
    map = $.goMap.getMap()
    _infoBub = new InfoBubble
      disableAnimation: true
      maxWidth: 500
      maxHeight: 300
      arrowStyle: 2
      content: @content
      backgroundClassName: 'map-bubble-background'
      borderRadius: 0
    _infoBub.open map, @marker

    google.maps.event.addListener _infoBub,'closeclick', =>
      map.setOptions
        zoomControl: true
        panControl: true
        mapTypeControl: true

    map.setOptions
      zoomControl:false
      panControl:false
      mapTypeControl: false
    window.infoBubble = _infoBub

    # TODO: feel like cheating waiting 200ms and then binding events
    _.delay @bindShareButtons, 200
    _.delay Youngagrarians.trackOutboundLinks, 200

  bindShareButtons: =>
    $("#map-popup-#{@model.id} .share .twitter").on 'click', (e) =>
      e.preventDefault()

      text = "Check out this great resource! #{@model.get('name')}"
      win_options = 'width=550,height=420,scrollbars=yes,resizable=yes,toolbar=no,location=yes'
      twitter_options =
        url: @model.locUrl()
        via: 'youngagrarians'
        text: text
      window.open("https://twitter.com/intent/tweet?#{$.param(twitter_options)}", 'Tweet', win_options)

    $("#map-popup-#{@model.id} .share .facebook").on 'click', (e) =>
      e.preventDefault()
      img = $("#fb_img").data('img')
      data =
        method: 'feed'
        name: "YoungAgrarians Map: " + @model.get('name')
        link: @model.locUrl()
        picture: img
        caption: 'A location on the YoungAgrarians Resource Map'
        description: @model.get("description")

      FB.ui data, (response) ->
        console.log 'response: ', response

  getLocation: =>
    { lat: @model.get('latitude'), long: @model.get('longitude') }

  hideMarker: =>
    @marker.setVisible false

  showMarker: =>
    @marker.setVisible true

  onRender: () =>
    @$el.hide();
