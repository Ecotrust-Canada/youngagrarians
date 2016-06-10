
<search>

  <input type="text" placeholder="Search: ie) Bees, Soil, etc." name="q" class="search-box search-box-map" onkeyup={ onfilter }>
  
  <div class='results-toggle toggle' onclick={ toggle_results }>list</div>

  <div class='category-toggle toggle' onclick={ toggle_categories }>
    <div class='notification' if={ num_cats_showing() }>{ num_cats_showing() }</div>
    CATEGORY
  </div>
  <ul if={ showing } class='category-panel panel'>
    <li each={ key, value in categories } class='panel-item' value="{ key }" onclick={ oncategorize }>
      { key }
      <span if={ value.showing } class='on'>&#x2714;</span>
    </li>
  </ul>

  this.categories = opts.categories;
  
  var controller = this
     ,query = opts.kwargs['q']
     ,category = opts.kwargs['c']
     ,active_tag = opts.kwargs['t']
     ,orig_listings
     ,showing=false;

  num_cats_showing(){
    var num_cats = Object.keys(controller.categories).filter(function(cat){ return controller.categories[cat].showing; }).length;
    return num_cats;
  }

  toggle_results(){
    var rl = document.querySelector('results');
    if (rl.className) {
      rl.className='';
    } else {
      rl.className='show';
    }
  }

  toggle_categories(){
    controller.showing = !controller.showing;
  }

  function listing_visible(item)
  {
    if (active_tag) {
      return item.categories.find( function(x){
        return x.name === active_tag || x.meta.name === active_tag;
      });
    } else {
      return item.categories.find( function(x){
        return category_cache[x.name] || category_cache[x.meta.name];
      });
    }
  }

  onfilter(e){
    query = e.target.value;
    filter_listings();
  }

  oncategorize(e){
    active_tag = null;
    controller.categories[e.item.key].showing = !controller.categories[e.item.key].showing;
    filter_listings();
  }
  
  opts.on('update_tag', function(tag){
    active_tag = tag;
    filter_listings();
  });

  opts.on('initial_load', function(listings){
    orig_listings = listings;

    // initial categories
    if (category) {
      controller.categories[category].showing = true
      controller.update();
      opts.trigger('categorize', controller.categories);
    }

    // initial query.
    if (query) {
      controller.q.value = query;
    }

    filter_listings();

  });
  
  function filter_listings(){
    category_cache = {};
    for(var cat in controller.categories) {
      if(controller.categories[cat].showing)
      {
        category_cache[cat] = 1;
        controller.categories[cat].tags.forEach(function(tag)
        {
          category_cache[tag] = 1;
        }); 
      }
    }
    var current_listings = [];
    var matches = 0;
    if( query )
    {
      var path = opts.kwargs['surrey'] ? '/surrey.json' : '/locations.json'
      path += '?q=' + query;
      ajax().get( path ).then(function(response){
        var l = response.filter( function(x){ return listing_visible( x ); } );
        opts.trigger('load', l );
      } );
    }
    else
    {
      var l = orig_listings.filter( function(x){ return listing_visible( x ); } );
      opts.trigger('load', l );
    }
  }

</search>
