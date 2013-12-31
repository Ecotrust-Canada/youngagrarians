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

  #TODO: can probably use compass to optimize these into a spritemap (avoid 16 http requests)
  getIcon: =>
    return '/assets/map-icons/tiny/' + @get('name').toLowerCase().replace(' ', '-') + ".png"
  
  getMapIcon: =>
    return '/assets/map-icons/small/' + @get('name').toLowerCase().replace(' ', '-') + ".png"

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
