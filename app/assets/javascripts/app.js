
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
riot.compile(function( x ) {
  riot.mount('search', pubsub);
  riot.mount('layers', pubsub);
  riot.mount('listing', pubsub);
  riot.mount('results', pubsub);
});

function slug(category){
  var rVal = category.meta ? category.meta.name.toLowerCase() : category.name.toLowerCase();
  return rVal.replace(/\s/g,'-');
}

ajax().get( pubsub.kwargs['surrey'] ? '/surrey.json' : '/locations.json').then(function(response){
  setTimeout(function(){
    response.forEach(function(listing){
      listing.dist = Math.abs((listing.latitude || 999) - 49.104430) + Math.abs((listing.longitude || 999) - -122.801094);
    });
    pubsub.trigger('initial_load', response);
  })
});

// the get-info button.
addEvent(document.body, 'click', function(e){
  if (e.target.className && e.target.className.indexOf && e.target.className.indexOf('info') > -1) {
    pubsub.trigger('detail', e.target.getAttribute('data-id'));
  }
})
