<layers>

  <div class='layer-toggle toggle' onclick={ toggle }>
    <div class='notification' if={ num_layers_showing() }>{ num_layers_showing() }</div>
  </div>

  <ul class='layer-panel panel' if={ showing }>
    <li class='panel-item' each={ wms_layers } onclick={ layer_on_off }>
      <span class="legend-item { legend_class }" style="{ legend_style }"></span> { name }
      <span if={ map_has_layer(layer) } class='on'>&#x2714;</span>
    </li>
  </ul>

  var controller=this
    , showing=false;

  controller.wms_layers = wms_layers;
  
  num_layers_showing(){
    var num_showing = controller.wms_layers.filter(function(layer){ return map.hasLayer(layer.layer) }).length
    return num_showing;
  }

  toggle(){
    controller.showing = !controller.showing;
  }

  map_has_layer(layer){
    return map.hasLayer(layer);
  }

  layer_on_off(e){
    if (map.hasLayer(e.item.layer)) {
      map.removeLayer(e.item.layer);
    }
    else{
      map.addLayer(e.item.layer);
    }
  }


</layers>
