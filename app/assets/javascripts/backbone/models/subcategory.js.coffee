class Youngagrarians.Models.Subcategory extends Backbone.RelationalModel
  paramRoot: 'subcategories'

  defaults:
    name: null

  getIcon: =>
    return '/images/map-icons/' + @get('name').toLowerCase().replace(' ', '-') + ".png"

  removeEvent: "subcategory:remove"

Youngagrarians.Models.Subcategory.setup()

class Youngagrarians.Collections.SubcategoryCollection extends Backbone.Collection
  model: Youngagrarians.Models.Subcategory
  url: '/subcategories'
