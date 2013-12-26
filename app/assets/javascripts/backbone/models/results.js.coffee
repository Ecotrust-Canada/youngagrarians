class Youngagrarians.Collections.ResultsCollection extends Backbone.Collection
  model: Youngagrarians.Models.Location
  
  initialize: (options)=>
    @locations = options.locations
    @currentProvice = null
    @currentBioregion = null
    @currentTerms = null
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
  
  search: (options)=>
    promise = $.ajax 
      url: '/search'
      type: 'POST'
      data: 
        term: options.term
      dataType: 'json'
    promise.done (data)=>
      @searchLocations = data 
      @update()
      options.complete() if options.complete
    
  clearSearch: =>
    if @searchLocations
      @searchLocations = null
      @update()
   
  update: =>
    locations = []
    @selectedCategories.each (category)=>
      locations = _.union locations, @locations.filter (location)=>
        location.get('category').id == category.id
    @selectedSubcategories.each (subcategory)=>
      locations = _.union locations, @locations.filter (location)=>
        _.find location.get('subcategories'), (s)->
          subcategory.id == s.id
    if @selectedSubcategories and @selectedCategories and @searchLocations
      locations = @locations.models
    if @currentSubdivision
      locations = _.filter locations, (location)=>
        location.get('province_code') == @currentSubdivision.code
    if @currentBioregion
      locations = _.filter locations, (location)=>
        location.get('bioregion') == @currentBioregion.name
    if @searchLocations
      locations = _.filter locations, (location)=>
        _.contains @searchLocations, location.id
    locations = _.sortBy locations, (location)->
      location.get('name').toLowerCase() if location.get('name')
    @.reset _.uniq(locations)

