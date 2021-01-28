package scenes;

import library.systems.BackgroundGridRenderSystem;
import feint.input.device.Keyboard.KeyCode;
import library.systems.SpriteRenderSystem;
import library.systems.SpriteAnimationSystem;
import library.components.PositionComponent;
import feint.assets.Assets;
import feint.graphics.Sprite;
import library.components.SpriteComponent;
import feint.forge.Forge;
import feint.renderer.Camera;
import feint.renderer.Renderer;
import feint.scene.Scene;

class CamerasScene extends Scene {
  var forge:Forge;
  var backgroundCamera:Camera;
  var uiCamera:Camera;

  override function init() {
    super.init();

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
    forge = new Forge();
    forge.createEntity([new PositionComponent(0, 0), new SpriteComponent(playerSprite)]);
    forge.addSystem(new SpriteAnimationSystem());
    forge.addRenderSystems(
      [new BackgroundGridRenderSystem(backgroundCamera), new SpriteRenderSystem()]
    );
  }

  override function update(elapsed:Float) {
    super.update(elapsed);

    forge.update(elapsed);

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
  }

  override function render(renderer:Renderer) {
    super.render(renderer);

    renderer.camera = camera;
    forge.render(renderer);

    renderer.camera = camera;
    renderer.drawRect(0, 100, 50, 50, 0, {color: 0xFF00FFFF});
    renderer.drawText(0, 100, 'World', 16, 'sans-serif');
    renderer.submit();

    renderer.camera = uiCamera;
    renderer.drawRect(0, 200, 50, 50, 0, {color: 0xFFFF00FF});
    renderer.drawText(0, 200, 'UI', 16, 'sans-serif');
    renderer.submit();
  }
}
