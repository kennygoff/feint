package scenes;

import feint.renderer.Renderer;
import feint.scene.Scene;

class SandboxScene extends Scene {
  override function render(renderer:Renderer) {
    super.render(renderer);

    renderer.drawRect(50, 50, 100, 25, {color: 0xFF00FFFF});
    renderer.drawRect(200, 200, 50, 50, {color: 0xFFFF00FF});
    renderer.drawRect(300, 100, 75, 75, {color: 0xFFFFFF00});
    // renderer.drawText(0, 0, "Sandbox", 32, "sans-serif");
  }
}
