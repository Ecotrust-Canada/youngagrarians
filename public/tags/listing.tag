<listing>

  <div class='listing-detail' if={ listing }>
    <div class='listing-header { slug(listing.categories.first.parent.toLowerCase()) }'>
      <div class='category-icon' style='background-image:url({ CATEGORY_ICONS[listing.categories.first.parent.toLowerCase()]})'></div>
      { listing.categories.first.name }
      <img src='/images/umap-content-title.png'>
      <div class="filled"></div>
    </div>
    <div class='back' onclick={ close }>Return to Listings</div>
    <h1>{ listing.name }</h1>
    <p>{ listing.description }</p>
    <h3>Learn More</h3>
    <p><a href="{ url }">{ listing.url }</a></p>
    <p>{ listing.street_address }, { listing.city }, { listing.province }, { listing.postal }</p>
  </div>

  var controller = this;
    
  slugify(category) {
    return slug(category)
  }
  
  close(){
    controller.listing = null;
  }

  opts.on('detail', function(listing_id){
    var listing = controller.listings.filter(function(l){return l.id == listing_id})[0];

    controller.update({
      listing: listing
    });
  });

  opts.on('load', function(listings){
    controller.listings = listings;
    });
</listing>
