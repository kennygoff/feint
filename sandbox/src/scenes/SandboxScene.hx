package scenes;

import feint.graphics.Sprite;
import feint.assets.Assets;
import feint.renderer.Renderer;
import feint.scene.Scene;

class SandboxScene extends Scene {
  var sprite:Sprite;

  override function init() {
    super.init();
    sprite = new Sprite(Assets.platformer_character__png);
    sprite.textureWidth = 384;
    sprite.textureHeight = 192;
    sprite.setupSpriteSheetAnimation(96, 96, ['idle' => [0], 'jump' => [1], 'run' => [2, 3]]);
    sprite.animation.play('run', 30, true);
  }

  override function update(elapsed:Float) {
    super.update(elapsed);

    if (!Math.isNaN(elapsed)) {
      sprite.animation.update(elapsed);
    }
  }

  override function render(renderer:Renderer) {
    super.render(renderer);

    renderer.drawImage(0, 0, Assets.icon__png, {
      x: 128,
      y: 128,
      width: 256,
      height: 256
    }, 1, 512, 512);
    renderer.drawRect(50, 50, 100, 25, {color: 0xFF00FFFF});
    renderer.drawRect(200, 200, 50, 50, {color: 0xFFFF00FF});
    renderer.drawRect(300, 100, 75, 75, {color: 0xFFFFFF00});
    renderer.drawImage(100, 100, Assets.inwave_labs_discord__png, {
      x: 0,
      y: 0,
      width: 100,
      height: 100
    });
    renderer.drawImage(300, 200, Assets.icon__png, {
      x: 0,
      y: 0,
      width: 100,
      height: 100
    });
    renderer.drawText(0, 0, "Sandbox", 32, "sans-serif");

    sprite.drawAt(0, 0, renderer);

    renderer.drawText(0, 0, 'FPS: ${game.fps}', 16, 'sans-serif');
  }
}
