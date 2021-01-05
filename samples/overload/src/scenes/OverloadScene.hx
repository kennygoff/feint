package scenes;

using Lambda;

import feint.input.device.Keyboard.KeyCode;
import feint.renderer.Renderer;
import feint.scene.Scene;
import feint.graphics.Sprite;

class OverloadScene extends Scene {
  final backgroundColor:Int = 0xFF000000;
  var sprites:Array<Sprite> = [];

  override public function init() {
    for (i in 0...3000) {
      var sprite = new Sprite('kenney-character-spritesheet');
      // TODO: Automate this!
      sprite.textureWidth = 384;
      sprite.textureHeight = 192;
      sprite.setupSpriteSheetAnimation(96, 96, ['idle' => [0], 'jump' => [1], 'run' => [2, 3]]);
      sprite.animation.play('run', 30);
      sprites.push(sprite);
    }
  }

  override public function update(elapsed:Float) {
    super.update(elapsed);

    for (sprite in sprites) {
      sprite.animation.update();
    }
  }

  override public function render(renderer:Renderer) {
    // Render background
    renderer.drawRect(0, 0, game.window.width, game.window.height, {color: backgroundColor});

    super.render(renderer);

    for (sprite in sprites) {
      sprite.drawAt(
        Math.floor(Math.random() * game.window.width),
        Math.floor(Math.random() * game.window.height),
        renderer
      );
    }

    // Render FPS
    renderer.drawText(4, 4, 'FPS: ${game.fps}', 16, 'sans-serif');
  }
}
