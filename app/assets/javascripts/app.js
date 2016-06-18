
var pubsub = riot.observable();

// parse hash vars.
pubsub.kwargs = {};
(window.location.hash + '').substr(1).split("&").forEach(function(part){
  var key = part.split("=")[0];
  var val = part.split("=")[1] || true;
  pubsub.kwargs[key] = val
});

pubsub.categories = {
    'network': {
      tags:['Market', 'Web Resource', 'Event', 'Organization'],
      showing: !pubsub.kwargs['c']
    },
    'education': {
      tags:['Education', 'Publication', 'Web Resource'],
      showing: !pubsub.kwargs['c']
    },
    'jobs-training': {
      tags:['Job', 'Apprenticeship', 'Funding'],
      showing: !pubsub.kwargs['c']
    },
    'business': {
      tags:['Infrastructure', 'Business', 'Funding', 'Market'],
      showing: !pubsub.kwargs['c']
    },
    'land': {
      tags:['Land'],
      showing: !pubsub.kwargs['c']
    },
    'run-your-farm': {
      tags:['Seed', 'Business'],
      showing: !pubsub.kwargs['c']
    }
};


function slug(category){
  var rVal;
  if (typeof(category) === 'string') {
    rVal = category;
  } else {
    rVal = category.primary.name ? category.primary.name : category.name;
  } 
  return rVal.toLowerCase().replace(/\s/g,'-');
}

ajax().get( '/locations.json' ).then(function(response){
  setTimeout(function(){
    cats = {};
    console.log(response);
    response.forEach(function(listing){
      listing.dist = Math.abs((listing.latitude || 999) - 49.104430) + Math.abs((listing.longitude || 999) - -122.801094);
      listing.categories.forEach(function(cat){
        cats[cat.name] = cats[cat.name] || 0;
        cats[cat.name] ++;
      })
    });
    console.log(cats);
    pubsub.trigger('initial_load', response);
  })
});

// the get-info button.
addEvent(document.body, 'click', function(e){
  if (e.target.className && e.target.className.indexOf && e.target.className.indexOf('info') > -1) {
    pubsub.trigger('detail', e.target.getAttribute('data-id'));
  }
})

// media query
var mq = window.matchMedia( "(max-width: 768px)" );
if (mq.matches) {
  window.mobile = true;
}
