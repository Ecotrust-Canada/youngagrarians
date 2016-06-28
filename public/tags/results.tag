
<results>

  <div class='results-sidebar' onscroll={ scroll }>
    <div class="content-logo-wrap">
      <img src="/images/umap-text-inverted.png">
    </div>

    <span class="cat-count show-all-count" if={ tag }><span class="filled show-all" onclick={ set_tag_null }>Show All&nbsp;<b></b></span></span>

    <div class="meta-nav">
      <a each="{ meta_tags }" onclick={ set_tag } class='{ active: tag === name }'>
        <img src="/images/icon/{ slugify(name) }.png">
      </a>
    </div>

    <div class='cat-counts'>
      <span each="{ name, value in cat_counts }" onclick={ set_tag } class="cat-count { name.toLowerCase().replace(/[^a-z]/g,'-') }"><span class="filled">
        { name }&nbsp;<b>{ value }</b>&nbsp;
      </span> </span>
    </div>

    <ul class='results-list' id='results-list'>
      <li each={ items } class="{ slugify(categories[0]) } lightbg">
        <div if={ CATEGORY_ICONS[slugify( categories[0] )] } class='listing-icon'
             style='background:url( { CATEGORY_ICONS[slugify( categories[0] )] }) 10px 10px no-repeat'
        ></div>
        <a class='listing-text' target='{ is_mobile() ? "_self" : "_blank" }' href='/locations/{ id }'>
          <label class='{ slugify(categories[0]) }'>{ categories[0].primary.name || categories[0].name }</label>
          <span class='name'>{ name }</span><br>
          <span if={ city } class='city'>{ city }, { province }</span>
        </a>
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
  this.meta_tags = [
    {name:'Network'},
    {name:'Education'},
    {name:'Jobs & Training'},
    {name:'Business'},
    {name:'Land'},
    {name:'Run Your Farm'}
  ];

  is_mobile(){
    return window.mobile;
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
    if (controller.tag === e.item.name) {
      if (is_meta(controller.tag)) {
        opts.trigger('update_tag', null);
      } else {
        var meta = PRIMARY_CATEGORIES.filter(function(c){return e.item.name === c.name})[0].metaName;
        console.log('meta', meta);
        opts.trigger('update_tag', meta);
      }
    } else {
      opts.trigger('update_tag', e.item.name);
    }
  }

  set_tag_null(e){
    opts.trigger('update_tag', null)
  }

  view_on_map(e) {
    if (window.mobile) {
      window.location = '/locations/'+e.item.id;
    } else {
      pubsub.trigger('zoom_to', e.item.marker)
    }
  }

  slugify(category) {
    return slug(category)
  }

  opts.on('update_tag', function(t){
    controller.update({
      tag: t
    });
  });
  
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

    var cat_counts = {}, name;
    var _is_meta = is_meta(controller.tag);
    response.forEach(function(item){
      for (var i=0; i<item.categories.length; i++) {
        if(_is_meta) {
          if (!controller.tag || item.categories[i].meta.name == controller.tag) {
            name = item.categories[i].primary ? item.categories[i].primary.name : item.categories[i].name;
            cat_counts[name] = (cat_counts[name] || 0) + 1;
          }
        } else {
          name = item.categories[i].primary ? item.categories[i].primary.name : item.categories[i].name;
          if (name === controller.tag) {
            cat_counts[name] = (cat_counts[name] || 0) + 1;
          }
        }
      }
    });

    controller.response = response;
    controller.update({
      items: response.slice(0,30),
      cat_counts: cat_counts
    });

  });


</results>
