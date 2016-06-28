
var pubsub = riot.observable();

var set_kwargs = function(){
  // parse hash vars.
  pubsub.kwargs = {};
  (window.location.hash + '').substr(1).split("&").forEach(function(part){
    var key = part.split("=")[0];
    var val = part.split("=")[1] || 'true';
    pubsub.kwargs[key] = decodeURIComponent(val)
  });
};
set_kwargs();


function slug(category){
  if (!category) return null;
  var rVal;
  if ((typeof category) === 'string') {
    rVal = category;
  } else {
    rVal = (category.primary && category.primary.name) ? category.primary.name : category.name;
  } 
  return rVal.toLowerCase().replace(/\s/g,'-');
}


// if it has an icon, it's a primary category (not meta).
function is_meta(category_str){
  return !CATEGORY_ICONS[slug(category_str)];
}


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


riot.tag('raw', '<span></span>', function (opts) {
  this.updateContent = function () {
      this.root.innerHTML = opts.content;
  };

  this.on('update', function() {
      this.updateContent();
  });

  this.updateContent();
});



function locationHashChanged() {
    set_kwargs();
    console.log('tag changed to', pubsub.kwargs['t']);
    pubsub.trigger('update_tag', pubsub.kwargs['t']);
}

window.onhashchange = locationHashChanged;