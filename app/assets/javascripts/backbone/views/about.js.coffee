class Youngagrarians.Views.About extends Backbone.Marionette.View
  template: 'backbone/templates/about'
  className: 'thing'

  events:
    'click .close'    : 'close'

  initialize: (options) =>
    _.bindAll @, 'render', 'close'

  render: =>
    @$el.html JST[ @template ] {}
    $("#app-modal").html(@el).foundation('reveal', 'open')

  close: (e) =>
    @$('a.close-reveal-modal').trigger('click')
