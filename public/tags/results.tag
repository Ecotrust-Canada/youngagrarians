
<results>

  <div class='results-sidebar'>
    <div class="content-logo-wrap">
      <img src="/images/umap-text.png">
    </div>

    <div class='cat-counts'>
      <span each="{ name, value in cat_counts }" class="cat-count { name.toLowerCase().replace(/\s/,'-') }"><span class="filled">
        { name }&nbsp;<b>{ value }</b>
      </span></span> 
    </div>

    <ul class='results-list'>
      <li each={ items }>
        <div class='listing-icon'
             style='background:url( { CATEGORY_ICONS[slugify( categories[0] )] }) 10px 10px no-repeat'
        ></div>
        <p class='listing-text'>
          <label class='{ slugify(categories[0]) }'>{ categories[0].meta.name || categories[0].name }</label>
          { name }<br>
          <span if={ city } class='city'>{ city }, { province }</span>
        </p>
        <div if={ latitude } class='view-on-map { slugify(categories[0]) }' onclick={ view_on_map }>
          VIEW ON<br>MAP
          <div class='triangle-arrow filled'></div>
        </div>
      </li>
    </ul>

  </div>

  var controller = this;
  var category_cache = {};

  this.items = opts.items;
  this.cat_counts = {};

  view_on_map(e) {
    pubsub.trigger('zoom_to', e.item.marker)
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
    response.forEach(function(item){
      for (var i=0; i<1; i++) {
        name = item.categories[i].meta.name || item.categories[i].name;
        cat_counts[name] = (cat_counts[name] || 0) + 1
      }
    });
    console.log(cat_counts);

    controller.update({
      items: response,
      cat_counts: cat_counts
    });

  });


</results>
