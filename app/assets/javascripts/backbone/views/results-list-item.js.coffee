class Youngagrarians.Views.ResultItem extends Backbone.Marionette.ItemView
  template: "backbone/templates/result-item"
  tagName: "li"
  className: "result-item"

  serializeData: =>
    data = @model.toJSON()
    data.img = @model.get('category').getMapIcon()
    data.locUrl = @model.locUrl()
    data

  initialize: (options) ->
    @app = options.app
