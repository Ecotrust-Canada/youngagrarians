
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
  maxZoom: 17,
  attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>'
});

map.addLayer(OpenStreetMap_BlackAndWhite);

function onLocationFound(e) {
    var radius = e.accuracy / 2;

    L.marker(e.latlng).addTo(map)
        .bindPopup("You are within " + radius + " meters from this point").openPopup();
    map.panTo(e.latlng);
    L.circle(e.latlng, radius).addTo(map);
}

map.on('locationfound', onLocationFound);

bounds = map.getBounds();
url = "parks/within?lat1=" + bounds.getSouthWest().lat + "&lon1=" + bounds.getSouthWest().lng + "&lat2=" + bounds.getNorthEast().lat + "&lon2=" + bounds.getNorthEast().lng;  

var geo;

function getSoil(e){
  if (geo) map.removeLayer(geo);
  var bounds = map.getBounds();
  var url = "/soils.json?lat1=" + bounds.getSouthWest().lat + "&lon1=" + bounds.getSouthWest().lng + "&lat2=" + bounds.getNorthEast().lat + "&lon2=" + bounds.getNorthEast().lng;
  var request = ajax().get(url).then(function(response){
    var json = {
      "type": "FeatureCollection",
      "features": response
    }
    geo = L.geoJson(json, {
      style:{
        "color": "#ff7800",
        "weight": 2,
        "opacity": 0.35
      }
    }).addTo(map);
  });
}

function getFN(e){

  var url = "/fn.json";
  var request = ajax().get(url).then(function(response){

    var fn_layer = L.geoJson(response, {
      style: {

      },
      pointToLayer: function (feature, latlng) {
        var m = L.circleMarker(latlng, {
          radius: 5,
          fillColor: "#FFF",
          color: "#000",
          weight: 2,
          opacity: 1,
          fillOpacity: 1
        });
        m.bindLabel(feature.properties.Name);
        return m;
      }

    });

    wms_layers.push({
      layer: fn_layer,
      name: 'Aboriginal Bands',
      legend_class: 'bands',
      tooltip: "Aboriginal Band Locations",
      legend_style: 'background:#FFF; border: 1px solid #000; border-radius: 50%'
    });
  });

}


var get_cluster_class = function(markers) {
  var the_category = null;
  for (var i=0; i<markers.length; i++) {
    var categories = markers[i].item.categories
    for (var j=0; j<categories.length; j++) {
      var current_category_name = categories[j].primary.name || categories[j].name;
      if (the_category) {
        if (current_category_name !== the_category) {
          return 'mixed'
        }
      } else {
        the_category = current_category_name;
      }
    }
  }
  return slug(the_category) || 'mixed';
};

var markers = new L.MarkerClusterGroup({
  maxClusterRadius: 18,
  iconCreateFunction: function(cluster) {

    var cat_class = get_cluster_class(cluster.getAllChildMarkers());

    return new L.DivIcon({
      iconSize: [25, 25],
      html: '<div class="cluster-icon '
        + cat_class
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

// convert a human-typed phone number to a dialable one.
function get_dialable_phone(s){
  s = s.replace(/[^\d]/g,'');
  if (s.charAt(0) === '1') s = s.substr(1);
  s = s.substr(0,10);
  if (s.length < 10) return '';
  return s;
}

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
          + (listing.is_event && listing.show_until ? "<p class='description'>date: " + listing.show_until + "</p>" : "")
          +"<p class='description'><a href='"+listing.url+"'>" + listing.name + "</a></p>"
          +"<p class='contact'>"
            + (listing.phone ? "<a href='tel:" + get_dialable_phone(listing.phone) + "'>" + listing.phone + "</a>" : "")
            + (listing.phone && listing.email ? " | " : "")
            + (listing.email ? "<a href='mailto:'" + listing.email + ">" + listing.email + "</a>" : "")
          +"<p class='city'>" + listing.street_address + ', ' + listing_city( listing ) + "</p>"
        +"<a target='_blank' href='/locations/" + listing.id + "' class='info " + the_slug +"'>MORE INFO"
          +"<div class='triangle-arrow filled'></div>"
        +"</a>"
        +"<div class=clearfix></div>"
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

map.on('click', function(){
  pubsub.trigger('map_click');
});

pubsub.on('zoom_to', function(marker){ 
    if (map.getBounds().contains( marker.getLatLng()) && marker.map ) {
      marker.openPopup({
        autoPan:false
      });
    } else {
      markers.zoomToShowLayer(marker, function() {
        map.panTo(marker.getLatLng());
        marker.openPopup();
      });
    }
})

if (!is_embedded) {
  map.locate();

  function onLocationFound(e) {
      var radius = e.accuracy / 2;

      L.marker(e.latlng).addTo(map)
          .bindPopup("Your Location").openPopup();
      L.circle(e.latlng, radius).addTo(map);
      map.panTo(e.latlng);
  }

  map.on('locationfound', onLocationFound);
  map.whenReady(getFN);
}

// soil layer, disabled.
/*
map.on('dragend', getSoil);
map.on('zoomend', getSoil);
map.whenReady(getSoil);
*/

