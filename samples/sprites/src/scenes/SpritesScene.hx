package scenes;

using Lambda;

import feint.input.device.Keyboard.KeyCode;
import feint.renderer.Renderer;
import feint.scene.Scene;

class SpritesScene extends Scene {
  final backgroundColor:Int = 0xFF000000;

  override public function update(elapsed:Float) {
    super.update(elapsed);
  }

  override public function render(renderer:Renderer) {
    // Render background
    renderer.drawRect(0, 0, game.window.width, game.window.height, {color: backgroundColor});

    super.render(renderer);

    renderer.drawImage(100, 100, 'kenney-character');
    renderer.drawImage(300, 100, 'kenney-character-spritesheet', {
      x: 0,
      y: 0,
      width: 96,
      height: 96
    });
    renderer.drawImage(500, 100, 'kenney-character-spritesheet', {
      x: 192,
      y: 0,
      width: 96,
      height: 96
    }, 1.5);
  }
}
