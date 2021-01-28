package feint.scene;

import feint.renderer.Camera;

class Layer {
  var camera:Camera;

  public function new(camera:Camera) {
    this.camera = camera;
  }
}
