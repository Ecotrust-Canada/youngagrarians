
<results>

  <div class='results-sidebar'>
    <div class="content-logo-wrap">
      <img src="/images/umap-text.png">
    </div>

    <ul class='results-list'>
      <li each={ items }>
        <div class='listing-icon'
             style='background:url( { CATEGORY_ICONS[slugify( categories[0] )] }) 10px 10px no-repeat'
        ></div>
        <p class='listing-text'>
          <label class='{ slugify(categories[0]) }'>{ categories[0].parent || categories[0].name }</label>
          { name }<br>
          <span if={ city } class='city'>{ city }, { province }</span>
        </p>
        <div if={ latitude } class='view-on-map { slugify(categories[0].name) }' onclick={ view_on_map }>
          VIEW ON<br>MAP
          <div class='triangle-arrow filled'></div>
        </div>
      </li>
    </ul>

  </div>

  var controller = this;
  var category_cache = {};

  this.items = opts.items;
  
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

    controller.update({
      items: response
    });

  });


</results>
