class Youngagrarians.Views.LegendItem extends Backbone.Marionette.Layout
  template: "backbone/templates/sidebar/legend-item"
  tagName: "li"

  events:
    "click a.select-category": "selectCat"
    "click a.toggle-subcategories": "toggleSubcategories"
   
  regions:
    subcategories:  ".subcategory-container"
     
  initialize: (options) =>
    @app = options.app

  serializeData: =>
    data = @model.toJSON()
    data.img = @model.getIcon()
    data

  toggleSubcategories: =>
    unless @subcategoriesView
      @subcategoriesView = new Youngagrarians.Views.Subcategories
        app: @app
        collection: @model.get('subcategories')      
      @subcategories.show @subcategoriesView
    else
      @subcategories.$el.toggle()
    $icon = @$('.toggle-subcategories i')
    if $icon.attr('class') == 'icon-expand-alt'
      $icon.removeClass('icon-expand-alt').addClass('icon-collapse-alt')
    else
      $icon.removeClass('icon-collapse-alt').addClass('icon-expand-alt')

  selectCat: (e) =>
    e.preventDefault()
    @app.vent.trigger "category:add", @model
