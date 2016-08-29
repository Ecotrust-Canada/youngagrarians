
wms_layers = [];

/*
wms_layers.push({
  layer: L.tileLayer.wms("http://openmaps.gov.bc.ca/mapserver/freshwater-and-marine", {
    layers: 'GW_WATER_WELLS_WRBC_COMMERCIAL,GW_WATER_WELLS_WRBC_COMMUNITY,GW_WATER_WELLS_WRBC_DOMESTIC,GW_WATER_WELLS_WRBC_DWS,GW_WATER_WELLS_WRBC_IRRIGATION,GW_WATER_WELLS_WRBC_MUNICIPAL,GW_WATER_WELLS_WRBC_ABANDONED',
    format: 'image/png',
    transparent: true
  }),
  name: 'wells by owner'
});

wms_layers.push({
  layer: L.tileLayer.wms("http://openmaps.gov.bc.ca/mapserver/freshwater-and-marine", {
    layers: 'GW_WATER_WELLS_WRBC_OBSERVATION_ACTIVE,GW_WATER_WELLS_WRBC_OBSERVATION_INACTIVE,GW_WATER_WELLS_WRBC_OTHER_USE,GW_WATER_WELLS_WRBC_TEST,GW_WATER_WELLS_WRBC_UNKNOWN_USE',
    format: 'image/png',
    transparent: true
  }),
  name: 'wells by use'
});
*/

L.TileLayer.BetterWMS = L.TileLayer.WMS.extend({
  
  onAdd: function (map) {
    // Triggered when the layer is added to a map.
    //   Register a click listener, then do all the upstream WMS things
    L.TileLayer.WMS.prototype.onAdd.call(this, map);
    map.on('click', this.getFeatureInfo, this);
  },
  
  onRemove: function (map) {
    // Triggered when the layer is removed from a map.
    //   Unregister a click listener, then do all the upstream WMS things
    L.TileLayer.WMS.prototype.onRemove.call(this, map);
    map.off('click', this.getFeatureInfo, this);
  },
  
  getFeatureInfo: function (evt) {
    // Make an AJAX request to the server and hope for the best
    var url = this.getFeatureInfoUrl(evt.latlng),
        showResults = L.Util.bind(this.showGetFeatureInfo, this);
    ajax().get( url ).then(function(data){
        var err = typeof data === 'string' ? null : data;
        showResults(err, evt.latlng, data);
      }
    );
  },
  
  getFeatureInfoUrl: function (latlng) {
    // Construct a GetFeatureInfo request URL given a point
    var point = this._map.latLngToContainerPoint(latlng, this._map.getZoom()),
        size = this._map.getSize(),
        
        params = {
          request: 'GetFeatureInfo',
          service: 'WMS',
          srs: 'EPSG:4326',
          styles: this.wmsParams.styles,
          transparent: this.wmsParams.transparent,
          version: this.wmsParams.version,      
          format: this.wmsParams.format,
          bbox: this._map.getBounds().toBBoxString(),
          height: size.y,
          width: size.x,
          layers: this.wmsParams.layers,
          query_layers: this.wmsParams.layers,
          info_format: 'text/html'
        };
    
    params[params.version === '1.3.0' ? 'i' : 'x'] = point.x;
    params[params.version === '1.3.0' ? 'j' : 'y'] = point.y;
    
    return this._url + L.Util.getParamString(params, this._url, true);
  },
  
  showGetFeatureInfo: function (err, latlng, content) {
    if (err) { console.log(err); return; } // do nothing if there's an error
    
    // Otherwise show the content in a popup, or something.
    L.popup({ maxWidth: 800})
      .setLatLng(latlng)
      .setContent(content)
      .openOn(this._map);
  }
});

L.tileLayer.betterWms = function (url, options) {
  return new L.TileLayer.BetterWMS(url, options);  
};

wms_layers.push({
  layer: L.tileLayer.wms("http://openmaps.gov.bc.ca/mapserver/freshwater-and-marine", {
    layers: 'GW_WATER_WELLS_WRBC_WATER_WELLS',
    format: 'image/png',
    transparent: true
  }),
  name: 'Wells (zoom in)',
  legend_class: 'wells',
  legend_style: 'background:blue; border-radius:50%; border: 1px solid white',
  tooltip: "Please zoom in to a single lot/farm to see all wells."
});

wms_layers.push({
  layer: L.tileLayer.wms("http://openmaps.gov.bc.ca/mapserver/admin-boundaries", {
    layers: 'ALC_AGRI_LAND_RESERVE_POLYS',
    format: 'image/png',
    transparent: true,
    opacity: 0.5
  }),
  name: 'ALR',
  legend_class: 'alr',
  legend_style: 'background:#93D798; border: 1px solid #bbb',
  tooltip: "Agricultural Land Reserve boundaries."
});

wms_layers.push({
  layer: L.tileLayer.wms("http://openmaps.gov.bc.ca/mapserver/water-admin-boundaries", {
    layers: 'LWADM_WATMGMT_PREC_AREA_C',
    format: 'image/png',
    transparent: true,
    opacity: 0.5
  }),
  name: 'Water Admin.',
  legend_class: 'water',
  legend_style: 'background:lightblue',
  tooltip: "Boundaries of municipal water management jurisdiction."
});

wms_layers.push({
  layer: L.tileLayer.wms("http://openmaps.gov.bc.ca/mapserver/freshwater-and-marine", {
    layers: 'GW_AQUIFERS_CLASSIFICATION_PROD',
    format: 'image/png',
    transparent: true,
    opacity: 0.5
  }),
  name: 'Aquifer Prod.',
  legend_class: 'aquifers',
  legend_style: 'background:url(/images/aquifers-legend.png)',
  tooltip: "Aquifer production: <span style='color:#ff4444'>red is low</span>, <span style='color:yellow'>yellow is normal</span>, <span style='color:#44ff44'>green is high</span>"
});
