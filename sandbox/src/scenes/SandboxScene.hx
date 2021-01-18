package scenes;

import feint.renderer.Renderer;
import feint.scene.Scene;

class SandboxScene extends Scene {
  override function render(renderer:Renderer) {
    super.render(renderer);

    renderer.drawText(0, 0, "Sandbox", 32, "sans-serif");
  }
}
