package library.components;

import feint.forge.Component;

class SceneLayerComponent extends Component {
  public var layerId:String;

  public function new(layerId:String) {
    this.layerId = layerId;
  }
}
