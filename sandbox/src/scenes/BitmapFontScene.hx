package scenes;

import feint.graphics.DefaultBitmapFont;
import feint.graphics.BitmapText;
import feint.graphics.BitmapFont;
import library.systems.BackgroundGridRenderSystem;
import feint.input.device.Keyboard.KeyCode;
import feint.assets.Assets;
import feint.graphics.Sprite;
import feint.forge.Forge;
import feint.renderer.Camera;
import feint.renderer.Renderer;
import feint.scene.Scene;
import feint.library.SpriteComponent;
import feint.library.SpriteRenderSystem;
import feint.library.SpriteAnimationSystem;
import feint.library.PositionComponent;

class BitmapFontScene extends Scene {
  var backgroundCamera:Camera;
  var uiCamera:Camera;
  var rot:Float = 0.0;
  var bmFont:BitmapFont;
  var bmText:BitmapText;

  override function init() {
    super.init();

    bmText = new BitmapText("Hello, world!\nGoodbye, world!");

    // Layers & Cameras
    uiCamera = new Camera();
    backgroundCamera = new Camera();

    // Sprites
    var playerSprite = new Sprite(Assets.platformer_character__png);
    playerSprite.textureWidth = 384;
    playerSprite.textureHeight = 192;
    playerSprite.setupSpriteSheetAnimation(
      96,
      96,
      ['idle' => [0], 'jump' => [1], 'run' => [2, 3]]
    );
    playerSprite.animation.play('run', 30, true);

    // Forge
    forge.createEntity([new PositionComponent(0, 0), new SpriteComponent(playerSprite)]);
    forge.addSystem(new SpriteAnimationSystem());
    forge.addRenderSystems(
      [new BackgroundGridRenderSystem(backgroundCamera), new SpriteRenderSystem()]
    );
  }

  override function update(elapsed:Float) {
    super.update(elapsed);

    if (game.window.inputManager.keyboard.keys[KeyCode.W] == Pressed) {
      camera.translation = {
        x: camera.translation.x,
        y: camera.translation.y + (elapsed * 0.25)
      };
      backgroundCamera.translation = {
        x: backgroundCamera.translation.x,
        y: backgroundCamera.translation.y + (elapsed * 0.1)
      };
    } else if (game.window.inputManager.keyboard.keys[KeyCode.S] == Pressed) {
      camera.translation = {
        x: camera.translation.x,
        y: camera.translation.y - (elapsed * 0.25)
      };
      backgroundCamera.translation = {
        x: backgroundCamera.translation.x,
        y: backgroundCamera.translation.y - (elapsed * 0.1)
      };
    } else if (game.window.inputManager.keyboard.keys[KeyCode.A] == Pressed) {
      camera.translation = {
        x: camera.translation.x + (elapsed * 0.25),
        y: camera.translation.y
      };
      backgroundCamera.translation = {
        x: backgroundCamera.translation.x + (elapsed * 0.1),
        y: backgroundCamera.translation.y
      };
    } else if (game.window.inputManager.keyboard.keys[KeyCode.D] == Pressed) {
      camera.translation = {
        x: camera.translation.x - (elapsed * 0.25),
        y: camera.translation.y
      };
      backgroundCamera.translation = {
        x: backgroundCamera.translation.x - (elapsed * 0.1),
        y: backgroundCamera.translation.y
      };
    }

    rot += elapsed / 1000;
    if (rot > 2) {
      rot -= 4;
    }
    // rot = feint.utils.Math.clampFloat(rot, -2, 2);
  }

  override function render(renderer:Renderer) {
    super.render(renderer);

    renderer.camera = camera;
    renderer.drawRect(50, 100, 50, 50, 0, 0x5500FFFF, 1.0, 0.5);
    renderer.drawRect(50, 100, 50, 50, Math.PI * rot, 0xFF00FFFF, 1.0, 0.5);
    renderer.drawText(0, 100, 'World', 16, 'sans-serif');
    renderer.submit();

    renderer.camera = uiCamera;
    renderer.drawRect(0, 200, 50, 50, 0, 0xFFFF00FF, 1.0, 0.0);
    renderer.drawText(0, 200, 'UI', 16, 'sans-serif');
    renderer.submit();

    renderer.camera = uiCamera;
    bmText.draw(renderer, 0, 0, 64);
    renderer.submit();
  }
}
