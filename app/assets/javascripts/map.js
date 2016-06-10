
/**
 * variables map_center and map_zoom must be set
 */
var map = L.map('map', {
  center: map_center,
  zoom: map_zoom,
  zoomControl: false
});

//add zoom control with your options
L.control.zoom({
     position:'bottomleft'
}).addTo(map);

// https: also suppported.
var OpenStreetMap_Mapnik = L.tileLayer('http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
  maxZoom: 19,
  attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>'
});
var OpenStreetMap_BlackAndWhite = L.tileLayer('http://{s}.tiles.wmflabs.org/bw-mapnik/{z}/{x}/{y}.png', {
  maxZoom: 18,
  attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>'
});

map.addLayer(OpenStreetMap_BlackAndWhite);

map.locate({setView: true, maxZoom: 12});

bounds = map.getBounds();
url = "parks/within?lat1=" + bounds.getSouthWest().lat + "&lon1=" + bounds.getSouthWest().lng + "&lat2=" + bounds.getNorthEast().lat + "&lon2=" + bounds.getNorthEast().lng;  

var geo;




function getSoil(e){
  if (geo) map.removeLayer(geo);
  var bounds = map.getBounds();
  var url = "soil/within?lat1=" + bounds.getSouthWest().lat + "&lon1=" + bounds.getSouthWest().lng + "&lat2=" + bounds.getNorthEast().lat + "&lon2=" + bounds.getNorthEast().lng;
  var request = ajax().get(url).then(function(response){
    geo = {
      "type": "FeatureCollection",
      "features": JSON.parse(response)
    }
    geo = L.geoJson(geo, {
      style:{
        "color": "#ff7800",
        "weight": 5,
        "opacity": 0.65
      }
    }).addTo(map);
  });
}


var markers = new L.MarkerClusterGroup({
  maxClusterRadius: 20,
  iconCreateFunction: function(cluster) {
    
    // get most frequent category for coloring.
    var counters = {};
    var highest_counter_value = 0;
    var highest_counter = null;

    cluster.getAllChildMarkers().forEach(function(marker)
    {
      marker.item.categories.forEach( function( category )
      {
        var cn = ( category.parent || category.name ).toLowerCase();
        counters[cn] = (counters[cn] || 0) + 1;
        if (counters[cn] > highest_counter_value) {
          highest_counter_value = counters[cn];
          highest_counter = category;
        }
      } );
    });

    //console.log(counters, highest_counter);

    return new L.DivIcon({
      iconSize: [25, 25],
      html: '<div class="cluster-icon '
        +slug(highest_counter)
        +'"><div class="filled">' + cluster.getChildCount() + '</div></div>'
    });
  }
});


map.addLayer(markers);

if (typeof city_json !== 'undefined') {
  surrey_style = {
      fillColor: "#ffaa00",
      color: "#000",
      weight: 2,
      opacity: 0.7,
      fillOpacity: 0.1
  };
  ajax().get(city_json).then(function(response){
    L.geoJson(response, {style:surrey_style}).addTo(map);
  });
}

pubsub.on('load', function(response){
  updateMarkers(response);
});


function updateMarkers(response){
  markers.clearLayers();

  for (var i = 0; i < response.length; i++) {
    var listing = response[i];
    if (listing.latitude && listing.longitude) {
      var cat = listing.categories[0]; // TODO: show first applicable category

      var the_slug = slug( cat );
      var title = listing.name;
      var marker = L.marker(new L.LatLng(listing.latitude, listing.longitude), {
        icon: L.divIcon({
          html:'<div class="map-icon '
            + the_slug
            + '"><div class="filled"></div></div>',
          iconSize: [20, 20],
          iconAnchor: [10, 10],
          popupAnchor: [3, 0]
        }),
        title: title
      });

      // link items to markers and vice versa.
      marker.item = listing;
      listing.marker = marker;
      marker.bindPopup(
      "<div class='popup'>"
        +"<div class='listing-icon' style='background-image:url(" + CATEGORY_ICONS[the_slug] + ")'></div>"
        +"<label class='" + the_slug + "'>" + ( cat ? cat.name : 'no category' ) + "</label>"
          +"<p class='description'>" + listing.name + "</p><p class='city'>" + listing_city( listing) + "</p>"
        +"<a target='_blank' href='/locations/" + listing.id + "' class='info " + the_slug +"'>MORE INFO"
          +"<div class='triangle-arrow filled'></div>"
        +"</a>"
      +"</div>"
      );
      markers.addLayer(marker);
    }
  }
}

function listing_city( listing )
{
  var rVal = '';
  if( listing.city )
  {
    rVal += listing.city;
    if( listing.province )
    {
      rVal += ', ';
    }
  }
  if( listing.province )
  {
    rVal += listing.province;
  }
  return rVal;
}

pubsub.on('zoom_to', function(marker){ 
    //map.setZoom(12);
    map.panTo(marker.getLatLng());
    markers.zoomToShowLayer(marker, function() {
      map.panTo(marker.getLatLng());
      marker.openPopup();
    });
})

map.locate({setView: true, maxZoom: 16});
function onLocationFound(e) {
    var radius = e.accuracy / 2;

    L.marker(e.latlng).addTo(map)
        .bindPopup("You are within " + radius + " meters from this point").openPopup();

    L.circle(e.latlng, radius).addTo(map);
}

map.on('locationfound', onLocationFound);

/*
map.on('dragend', getSoil);
map.on('zoomend', getSoil);
map.whenReady(getSoil);
*/

