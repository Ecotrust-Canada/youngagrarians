
<results>

  <div class='results-sidebar' onscroll={ scroll }>
    <a class="content-logo-wrap" href="#">
      <img src="/images/umap-text-inverted.png">
    </a>

    <span class="cat-count show-all-count" if={ tag && !loading }><span class="filled show-all" onclick={ set_tag_null }>Show All&nbsp;<b></b></span></span>

    <div class="meta-nav">
      <a each="{ meta_tags }" onclick={ set_tag } class='{ active: tag === name }' title='{name}'>
        <img src="/images/icon/{ slugify(name) }.png">
      </a>
    </div>

    <div class='loading' if={ loading }></div>

    <div class='cat-counts' if={ !loading }>
      <span each="{ name, value in cat_counts }" onclick={ set_tag } class="cat-count { name.toLowerCase().replace(/[^a-z]/g,'-') }"><span class="filled">
        { name }&nbsp;<b>{ value }</b>&nbsp;
      </span> </span>
    </div>

    <ul class='results-list' id='results-list' if={ !loading }>
      <li each={ items } class="{ proper_category_slug } lightbg">
        <div if={ CATEGORY_ICONS[proper_category_slug] } class='listing-icon'
             style='background:url( { CATEGORY_ICONS[proper_category_slug] }) 10px 10px no-repeat'
        ></div>
        <a class='listing-text' target='{ is_mobile() ? "_self" : "_blank" }' href='/locations/{ id }'>
          <label class='{ proper_category_slug }'>{ proper_category }</label>
          <span class='name'>{ name }</span>
          <span if={ city } class='city'>{ city }, { province || 'BC' }</span>
        </a>
        <div if={ latitude } class='view-on-map { proper_category_slug }' onclick={ view_on_map }>
          <span>VIEW ON<br>MAP</span>
          <div class='triangle-arrow filled'></div>
        </div>
      </li>
    </ul>

    <p style='padding:10px' class='has-more-msg' if={ has_more }>
      There are more results in other categories, please switch category to see them.
    </p>

  </div>

  var controller = this;
  var category_cache = {};
  
  this.items = opts.items;
  this.cat_counts = {};
  this.tag = opts.kwargs['t'];
  this.loading = true;
  this.has_more = false; // indicates whether other categories have more results.
  this.meta_tags = [
    {name:'Land'},
    {name:'Run Your Farm'}
  ];
   
  ellipsize(s, l){
    if (s.length > l) {
      return s.substr(0,l) + '..';
    } else {
      return s
    }
  }
  // additional categories for YA version.
  if (!is_embedded) {
    this.meta_tags = [
      {name:'Network'},
      {name:'Education'},
      {name:'Jobs & Training'},
      {name:'Business'}
    ].concat(this.meta_tags);
  }

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
    console.log(controller.tag === e.item.name);
    if (controller.tag === e.item.name) {
      if (is_meta(controller.tag)) {
        opts.trigger('update_tag_start', null);
      } else {
        var meta = PRIMARY_CATEGORIES.filter(function(c){return e.item.name === c.name})[0].metaName;
        opts.trigger('update_tag_start', meta);
      }
    } else {
      opts.trigger('update_tag_start', e.item.name);
    }
  }

  set_tag_null(e){
    opts.trigger('update_tag_start', null)
  }

  view_on_map(e) {
    if (window.mobile) {
      //window.location = '/locations/'+e.item.id;
      console.log('toggling')
      opts.trigger('toggle_results')
    }
    pubsub.trigger('zoom_to', e.item.marker)
    
  }

  slugify(category) {
    return slug(category)
  }

  opts.on('update_tag', function(t){
    controller.update({
      tag: t
    });
  });

  opts.on('loading', function(){
    controller.update({
      loading:true
    });
  });
  
  opts.on('load', function(response, has_more){
    
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
      var _cat_counts = {}; // keep a local count to avoid double counting children/parents.
      for (var i=0; i<item.categories.length; i++) {
        if(_is_meta) {
          if (!controller.tag || item.categories[i].meta.name == controller.tag) {
            name = item.categories[i].primary ? item.categories[i].primary.name : item.categories[i].name;
            _cat_counts[name] = 1; //(cat_counts[name] || 0) + 1;
            item.proper_category_slug = slug(name);
            item.proper_category = name;
          }
        } else {
          name = item.categories[i].primary ? item.categories[i].primary.name : item.categories[i].name;
          if (name === controller.tag) {
            _cat_counts[name] = 1; //(cat_counts[name] || 0) + 1;
            item.proper_category_slug = slug(name);
            item.proper_category = name;
          }
        }
      }
      for (k in _cat_counts) {
        if (k != 'null') {
          cat_counts[k] = (cat_counts[k] || 0) + 1; // yield the local counts into the global.
        }
      }
    });
    
    if (window.is_embedded) { // CoS hardcoded cateogory tag rendering restriction.
      var tmp = cat_counts;
      cat_counts = {};
      cat_counts['Services and Suppliers'] = tmp['Services and Suppliers'];
      cat_counts['Land Listings'] = tmp['Land Listings'];
    }

    controller.response = response;
    console.log(cat_counts);
    controller.update({
      items: response.slice(0,30),
      cat_counts: cat_counts,
      loading: false,
      has_more: has_more
    });

  });


</results>
