
<search>

  <input type="text" placeholder="Search: ie) Bees, Soil, etc." name="q" class="search-box search-box-map" onkeyup={ onquery }>
  
  <div class='results-toggle toggle' onclick={ toggle_results }>list</div>

  <!--<div class='category-toggle toggle' onclick={ toggle_categories }>
    <div class='notification' if={ num_cats_showing() }>{ num_cats_showing() }</div>
    CATEGORY
  </div>
  <ul if={ showing } class='category-panel panel'>
    <li each={ key, value in categories } class='panel-item' value="{ key }" onclick={ oncategorize }>
      { key }
      <span if={ value.showing } class='on'>&#x2714;</span>
    </li>
  </ul>-->

  //this.categories = opts.categories;
  
  var controller = this
     ,query = opts.kwargs['q']
     //,category = opts.kwargs['c']
     ,active_tag = opts.kwargs['t']
     ,orig_listings
     ,showing=false;

  toggle_results(){
    var rl = document.querySelector('results');
    if (rl.className) {
      rl.className='';
    } else {
      rl.className='show';
    }
  }

  function listing_visible(item)
  {
    if (active_tag) {
      var match_type = is_meta(active_tag) ? 'meta' : 'primary';
      return item.categories.find( function(x){
        return x.name === active_tag || x[match_type].name === active_tag;
      });
    } else {
      return true;
    }
  }

  onquery(e){
    query = e.target.value;
    orig_listings = null; // clear listings cache to force a trip to server.
    filter_listings();
  }

  function update_hash(){
    var hash_parts = [];
    if (active_tag) hash_parts.push("t=" + encodeURIComponent(active_tag));
    if (query) hash_parts.push("q=" + query);
    set_kwargs();
    window.location.hash = "#" + hash_parts.join("&");
  }
  
  opts.on('update_tag', function(tag){
    active_tag = tag;
    update_hash();
    filter_listings();
  });

  function handle_load(){
    console.log(is_meta(active_tag) ? 'meta' : 'primary');
    var l = orig_listings.filter( function(x){ return listing_visible( x ); } );
    opts.trigger('load', l );
  }

  function filter_listings(){
    if( !orig_listings )
    {
      var path = '/locations.json'
      if (query) path += '?q=' + query;
      ajax().get( path ).then(function(response){
        response.forEach(function(listing){
          listing.dist = Math.abs((listing.latitude || 999) - 49.104430) + Math.abs((listing.longitude || 999) - -122.801094);
        });
        orig_listings = response;
        console.log(response);
        handle_load();
      });
    }
    else
    {
      handle_load();
    }
  }
  if (query) {
    controller.q.value = query;
  }

  setTimeout(function(){
    filter_listings();  
  })
  

</search>
