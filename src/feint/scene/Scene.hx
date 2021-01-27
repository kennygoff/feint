package feint.scene;

import feint.renderer.Camera;
import feint.renderer.Renderer;

class Scene {
  var game:Game;
  var camera:Camera;

  public function new() {
    camera = new Camera();
  }

  public function init() {}

  public function update(elapsed:Float) {}

  public function render(renderer:Renderer) {}
}
