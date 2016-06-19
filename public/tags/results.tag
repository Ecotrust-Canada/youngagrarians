
<results>

  <div class='results-sidebar' onscroll={ scroll }>
    <div class="content-logo-wrap">
      <img src="/images/umap-text-inverted.png">
    </div>

    <div class='cat-counts'>
      <span if={ !tag }>CLICK ONE: </span>
      <span if={ show_current(tag) } onclick={ set_tag_null }>IN "{ tag.toUpperCase() }":</span>

      <span each="{ name, value in cat_counts }" onclick={ set_tag } class="cat-count { name.toLowerCase().replace(/[^a-z]/g,'-') }"><span class="filled">
        { name }&nbsp;<b>{ value }</b>&nbsp;
      </span> </span>
      
      <span class="cat-count" if={ tag }><span class="filled show-all" onclick={ set_tag_null }>Show All&nbsp;<b></b></span></span>
    </div>

    <ul class='results-list' id='results-list'>
      <li each={ items } class="{ slugify(categories[0]) } lightbg">
        <div if={ CATEGORY_ICONS[slugify( categories[0] )] } class='listing-icon'
             style='background:url( { CATEGORY_ICONS[slugify( categories[0] )] }) 10px 10px no-repeat'
        ></div>
        <p class='listing-text'>
          <label class='{ slugify(categories[0]) }'>{ categories[0].primary.name || categories[0].name }</label>
          { name }<br>
          <span if={ city } class='city'>{ city }, { province }</span>
        </p>
        <div if={ latitude } class='view-on-map { slugify(categories[0]) }' onclick={ view_on_map }>
          <span if={ is_mobile() }>GO TO<br>LISTING</span>
          <span if={ !is_mobile() }>VIEW ON<br>MAP</span>
          <div class='triangle-arrow filled'></div>
        </div>
      </li>
    </ul>

  </div>

  var controller = this;
  var category_cache = {};
  
  this.items = opts.items;
  this.cat_counts = {};
  this.tag = opts.kwargs['t'];

  is_mobile(){
    return window.mobile;
  }

  show_current(tag) {
    return tag && is_meta(tag);
  }
  
  // "infinite" scroll.
  scroll(e){
    if ( document.getElementById('results-list').offsetHeight - e.target.scrollTop < 1000) {
      controller.update({
        items: controller.response.slice(0,controller.items.length+10),
        })
    }
  }

  set_tag(e){
    this.tag = e.item.name;
    opts.trigger('update_tag', e.item.name);
  }

  set_tag_null(e){
    this.tag = null;
    opts.trigger('update_tag', null)
  }

  view_on_map(e) {
    if (window.mobile) {
      var win = window.open('/locations/'+e.item.id, '_blank');
      win.focus();
    } else {
      pubsub.trigger('zoom_to', e.item.marker)
    }
  }

  slugify(category) {
    return slug(category)
  }
  
  opts.on('load', function(response){
    
    response = response.sort(
      function(x, y)
      {
        if ( x.dist > y.dist) {
          return 1;
        } else if (x.dist < y.dist) {
          return -1
        } else {
          return 0;
        }
      }
    );

    var cat_counts = {};
    var match_type;
    if(controller.tag) {
      match_type = 'primary';
    } else {
      match_type = 'meta';
    }
    response.forEach(function(item){
      for (var i=0; i<item.categories.length; i++) {
        name = item.categories[i][match_type].name || item.categories[i].name;
        cat_counts[name] = (cat_counts[name] || 0) + 1
      }
    });

    controller.response = response;
    controller.update({
      items: response.slice(0,30),
      cat_counts: cat_counts
    });

  });


</results>
