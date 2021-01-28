package feint.scene;

import feint.renderer.Camera;

@:dox(hide)
class Layer {
  var camera:Camera;

  public function new(camera:Camera) {
    this.camera = camera;
  }
}
