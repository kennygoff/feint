package scenes;

using Lambda;

import feint.input.device.Keyboard.KeyCode;
import feint.renderer.Renderer;
import feint.scene.Scene;
import feint.graphics.Sprite;

class SpritesScene extends Scene {
  final backgroundColor:Int = 0xFF000000;
  var sprite:Sprite;

  override public function init() {
    sprite = new Sprite('kenney-character-spritesheet');
    // TODO: Automate this!
    sprite.textureWidth = 384;
    sprite.textureHeight = 192;
    sprite.setupSpriteSheetAnimation(96, 96, ['idle' => [0], 'jump' => [1], 'run' => [2, 3]]);
    sprite.animation.play('run', 30);
  }

  override public function update(elapsed:Float) {
    super.update(elapsed);

    sprite.animation.update();
  }

  override public function render(renderer:Renderer) {
    // Render background
    renderer.drawRect(0, 0, game.window.width, game.window.height, {color: backgroundColor});

    super.render(renderer);

    renderer.drawImage(0, 0, 'kenney-character');
    renderer.drawImage(150, 0, 'kenney-character-spritesheet', {
      x: 0,
      y: 0,
      width: 96,
      height: 96
    });
    renderer.drawImage(300, 0, 'kenney-character-spritesheet', {
      x: 192,
      y: 0,
      width: 96,
      height: 96
    }, 1.5);

    sprite.drawAt(200, 200, renderer);
  }
}
