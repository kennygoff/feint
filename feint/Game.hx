package feint;

import feint.renderer.Renderer;

class Game {
  var application:Application;
  var window:Window;
  var renderer:Renderer;

  public function new(renderer:Renderer) {
    this.renderer = renderer;
  }

  public function update(elapsed:Float) {}

  public function render() {
    renderer.clear();
  }
}
