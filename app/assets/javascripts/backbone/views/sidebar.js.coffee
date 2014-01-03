#= require ./sidebar/bioregions
#= require ./sidebar/provinces
class Youngagrarians.Views.Sidebar extends Backbone.Marionette.Layout
  template: "backbone/templates/sidebar"
  itemView: Youngagrarians.Views.SidebarItem

  regions:
    provinces:  "#map-provinces"
    bioregions: "#map-bioregions"
    legend:     "#map-legend-container"
    selectedCategories: '#map-selected-categories'
    selectedSubcategories: '#map-selected-subcategories'
    search:     "#map-search"
    extras:     "#extras"

  events:
    "click a.hide-show": "toggleLegend"

  initialize: (options) ->
    @app = options.app
    @data = options.data
    @provincesView = new Youngagrarians.Views.Provinces
      app: @app
    @legendView = new Youngagrarians.Views.Legend
      collection: @data.categories
      app: @app
    @searchView = new Youngagrarians.Views.Search
      app: @app
    @extrasView = new Youngagrarians.Views.Extras
      app: @app
      categories: @data.categories
      locations: @data.locations
    @selectedCategoriesView = new Youngagrarians.Views.SelectedCategories
      app: @app
      collection: options.results.selectedCategories
    @selectedSubcategoriesView = new Youngagrarians.Views.SelectedCategories
      app: @app
      collection: options.results.selectedSubcategories
    @app.vent.on 'province:change', @provinceChanged

  onRender: =>
    @extras.show @extrasView
    @search.show @searchView
    @provinces.show @provincesView
    @legend.show @legendView
    @selectedCategories.show @selectedCategoriesView
    @selectedSubcategories.show @selectedSubcategoriesView

  provinceChanged: (options)=>
    if options.country and options.subdivision
      country = _.findWhere Youngagrarians.Constants.COUNTRIES, {code: options.country}
      subdivision = _.findWhere country.subdivisions, {code: options.subdivision}
      if subdivision.bioregions.length > 0
        unless @bioregionView
          @bioregionView = new Youngagrarians.Views.Bioregions
            app: @app
        @bioregions.show @bioregionView
        @bioregionView.updateBioregions(options)
        @bioregionView.$el.show()
      else
        @bioregionView.$el.hide() if @bioregionView
    else
      @bioregionView.$el.hide() if @bioregionView
