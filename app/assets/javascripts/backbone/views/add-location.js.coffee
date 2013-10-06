class Youngagrarians.Views.AddLocation extends Backbone.Marionette.View
  template: 'backbone/templates/add-location'

  events:
    'click .cancel'                 : 'cancelAdd'
    'submit form#add-to-map-form'   : 'submitForm'
    'change select#category-select' : 'updateSubcategories'
    'click a#add-subcategory'       : 'addSubcategory'
    'change select#country'         : 'updateSubdivision'
    'change select#subdivision'     : 'updateBioregion'

  initialize: (options) =>    
    _.bindAll @, 'render', 'cancelAdd', 'submitForm'
    @categories = options.categories
    @locations = options.locations    
    
  renderCategories: =>    
    $categoryEl = @$('select#category-select')
    $categoryEl.append "<option value='-1'>Select a Category</option>"
    @categories.each (category)=>
      $categoryEl.append "<option value='#{category.id}'>#{category.get('name')}</option>"
    
  renderCountries: =>  
    $countryEl = @$('select#country')
    $countryEl.append "<option value='-1'>Select a Country</option>"
    _(Youngagrarians.Constants.COUNTRIES).each (country)=>
      $countryEl.append "<option value='#{country.code}'>#{country.name}</option>"
    
  updateSubdivision: =>
    country = @getCountry()
    if country and country.subdivisions.length > 0
      @$('#subdivision-control-group').show()
      $subdivisionEl = @$('select#subdivision')
      $subdivisionEl.html "<option value='-1'>Select a #{country.subdivision_name}</option>"
      _(country.subdivisions).each (subdivision)=>
        $subdivisionEl.append "<option value='#{subdivision.code}'>#{subdivision.name}</option>"
      @$('#subdivision-label').text country.subdivision_name
    else
      @$('#subdivision-control-group').hide()
      
  updateBioregion: =>    
    country = @getCountry()
    code = @$('select#subdivision option:selected').val()
    subdivision = _(country.subdivisions).findWhere
      code: code
    if subdivision and subdivision.bioregions.length > 0
      @$('#bioregion-control-group').show()
      $bioregionEl = @$('select#bioregion')
      $bioregionEl.html "<option value='-1'>Select a Bioregion</option>"
      _(subdivision.bioregions).each (bioregion)=>
        $bioregionEl.append "<option value='#{bioregion.name}'>#{bioregion.name}</option>"      
    else
      @$('#bioregion-control-group').hide()
  
  getCountry: =>
    countryCode = @$('select#country option:selected').val()
    _(Youngagrarians.Constants.COUNTRIES).findWhere 
      code: countryCode
    
        
  updateSubcategories: =>
    categoryId = parseInt(@$('select#category-select option:selected').val())        
    if categoryId != -1
      @$('#subcategories-control-group').show()    
      category = @categories.get categoryId
      subcategoryView = new Youngagrarians.Views.SubcategorySelect
        model: new Backbone.Model
          subcategories: category.get('subcategories')
          removable: false           
      @$('#subcategory-selects').html subcategoryView.render().el
    else
      @$('#subcategory-selects').empty()
      @$('#subcategories-control-group').hide()      
  
  addSubcategory: =>
    categoryId = parseInt(@$('select#category-select option:selected').val())
    if categoryId != -1
      category = @categories.get categoryId
      subcategoryView = new Youngagrarians.Views.SubcategorySelect
          model: new Backbone.Model
            subcategories: category.get('subcategories')
            removable: true           
        @$('#subcategory-selects').append subcategoryView.render().el
  
  cancelAdd: =>
    @$('a.close-reveal-modal').trigger('click')

  submitForm: (e) =>
    e.preventDefault()
    e.stopPropagation()

    agree = @$el.find("input#agree")
    if agree.is(":checked")
      location = $("input#location").val()      
      @model.set 'address', location
      
      #@model.set 'latitude', $.goMap.getMap().center.lat
      #@model.set 'longitude', $.goMap.getMap().center.lng

      categoryId = parseInt $("select#category-select").val()      
      if not _.isNaN(categoryId) and categoryId != -1 
        category = @categories.get categoryId
        @model.set 
          category_id: categoryId
          category: category
      else
        alert 'You must add a category'
        return     
      
      subcategories = new Youngagrarians.Collections.SubcategoryCollection
      _(@$("select.subcategory-select")).each (subcategoryEl)=>
        $subcategoryEl = $(subcategoryEl)
        subcategoryId = parseInt $subcategoryEl.val() 
        if not _.isNaN(subcategoryId) and subcategoryId != -1
          subcategories.add category.get('subcategories').get subcategoryId
      @model.set 'subcategories', subcategories
      
      if parseInt(@$('#country').val()) != -1
        @model.set 'country_code', @$('#country').val()
      else
        alert 'Please enter a country'
        return
      
      @model.set 'province_code', @$('#subdivision').val() unless parseInt(@$('#subdivision').val()) == -1      
       
      @model.set 
        postal: @$el.find('input#postal').val()        
        bioregion: @$('#bioregion').val()
        name: @$("input#name").val()
        description: @$('textarea#description').val()
        fb_url: @$('input#facebook').val()
        twitter_url: @$('input#twitter').val()
        url: @$('input#url').val()
        phone: @$('input#phone').val()
        email: @$("input#email").val()
        show_until: @$("input#show_until").val()
        
      @locations.create @model, wait: true
      @cancelAdd(e)
    else
      alert "You have to agree to the terms!"
  
  render: =>    
    @$el.html JST[ @template ](@model.toJSON())
    $("#app-modal").html @el
    @renderCategories()
    @renderCountries()
    @$el.foundation('reveal', 'open')
