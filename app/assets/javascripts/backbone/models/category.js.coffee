class Youngagrarians.Models.Category extends Backbone.RelationalModel
  paramRoot: 'category'

  defaults:
    name: null

  relations: [
    type: 'HasMany'
    key: 'subcategories'
    relatedModel: 'Youngagrarians.Models.Subcategory'
    includeInJSON: [Backbone.Model.prototype.idAttribute, 'name']
    collectionType: 'Youngagrarians.Collections.SubcategoryCollection'
    reverseRelation:
      key: 'location'
      includeInJSON: '_id'
  ]

  getIcon: =>
    return '/assets/map-icons/' + @get('name').toLowerCase().replace(' ', '-') + ".png"
  
  getMapIcon: =>
    return '/assets/map-icons/' + @get('name').toLowerCase().replace(' ', '-') + "-map.png"

  removeEvent: "category:remove"

Youngagrarians.Models.Category.setup()

class Youngagrarians.Collections.CategoriesCollection extends Backbone.Collection
  model: Youngagrarians.Models.Category
  url: '/categories'

  comparator: ( a, b ) =>
    aName = a.get('name')
    bName = b.get('name')
    if aName == bName
      return 0
    else if aName < bName
      return -1
    return 1
