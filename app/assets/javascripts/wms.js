
wms_layers = [];
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

wms_layers.push({
  layer: L.tileLayer.wms("http://openmaps.gov.bc.ca/mapserver/freshwater-and-marine", {
    layers: 'GW_WATER_WELLS_WRBC_WATER_WELLS,GW_WATER_WELLS_WRBC_WATER_UTILITY',
    format: 'image/png',
    transparent: true
  }),
  name: 'all wells'
});

