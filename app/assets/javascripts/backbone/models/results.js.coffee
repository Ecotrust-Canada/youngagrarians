class Youngagrarians.Collections.ResultsCollection extends Backbone.Collection
  model: Youngagrarians.Models.Location

  initialize: (options)=>
    @locations = options.locations
    @currentProvice = null
    @currentBioregion = null
    @currentTerms = null
    @searchResults = null
    @selectedCategories = new Backbone.Collection()
    @selectedSubcategories = new Backbone.Collection()

  addCategory: (category)=>
    @selectedCategories.reset([])
    @selectedSubcategories.reset([])
    @selectedCategories.add category
    category.get('subcategories').each (subcategory)=>
      subcategory = @selectedSubcategories.find (sub)->
        sub.id == subcategory.id
      @selectedSubcategories.remove subcategory if subcategory
    @update()

  removeCategory: (category)=>
    @selectedCategories.remove category
    @update()

  addSubcategory: (subcategory)=>
    @selectedCategories.reset([])
    category = @selectedCategories.find (cat)->
      cat.id == subcategory.get('category_id')
    @selectedSubcategories.add subcategory
    @update()

  removeSubcategory: (subcategory)=>
    @selectedSubcategories.remove subcategory
    @update()

  changeRegion: (options)=>
    stateChanged = !(options.subdivision == @currentSubdivision and options.bioregion == @currentBioregion)
    @currentSubdivision = @locations.getSubdivision options.country, options.subdivision
    @currentBioregion = @locations.getBioregion options.country, options.subdivision, options.bioregion
    @update() if stateChanged

  searchById: (id) => @.reset @locations.where(id: id)

  search: (options)=>
    promise = $.ajax
      url: '/search'
      type: 'POST'
      data:
        term: options.term
      dataType: 'json'
    promise.done (data)=>
      @searchResults = new Youngagrarians.Collections.LocationsCollection(data)
      @update()
      options.complete() if options.complete

  clearSearch: =>
    if @searchResults
      @searchResults = null
      @update()

  update: =>
    results = @locations.models
    # show nothing if user didn't search for anything
    if !@searchResults && !@selectedCategories.length && !@selectedSubcategories.length
      results = []

    # apply filters
    if @searchResults
      results = @searchResults.models

    @selectedCategories.each (category)=>
      results = _.filter results, (location)=>
        location.get('category').id == category.id

    @selectedSubcategories.each (subcategory)=>
      results = _.filter results, (location)=>
        _.find location.get('subcategories'), (s)->
          subcategory.id == s.id

    if @currentSubdivision
      results = _.filter results, (location)=>
        location.get('province') == @currentSubdivision.code

    if @currentBioregion
      results = _.filter results, (location)=>
        location.get('bioregion') == @currentBioregion.name

    results = _.sortBy results, (location)->
      location.get('name').toLowerCase() if location.get('name')

    @.reset _.uniq(results)

