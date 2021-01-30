package library.systems;

import feint.renderer.Renderer;
import feint.forge.Forge;
import feint.forge.System.RenderSystem;
import feint.renderer.Camera;

class BackgroundGridRenderSystem extends RenderSystem {
  var camera:Camera;

  public function new(camera:Camera) {
    this.camera = camera;
  }

  override function render(renderer:Renderer, forge:Forge) {
    renderer.camera = camera;

    renderer.drawRect(-50 * 32, -50 * 32, 100 * 32, 100 * 32, 0, 0xFF444444, 1.0, 0.9);

    for (x in -50...50) {
      for (y in -50...50) {
        renderer.drawRect((32 * x) + 1, (32 * y) + 1, 30, 30, 0, 0xFF777777, 1.0, 0.9);
      }
    }

    renderer.drawRect(0, 0, 50, 50, 0, 0xFFFFFF00, 1.0, 0.9);
    renderer.drawText(0, 0, 'Background', 16, 'sans-serif');

    renderer.submit();
  }
}
