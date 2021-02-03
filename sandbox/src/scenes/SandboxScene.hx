package scenes;

import feint.input.device.Keyboard.KeyCode;
import feint.forge.Entity;
import feint.forge.Forge;
import feint.graphics.Sprite;
import feint.assets.Assets;
import feint.renderer.Renderer;
import feint.scene.Scene;
import feint.library.SpriteRenderSystem;
import feint.library.SpriteAnimationSystem;
import feint.library.SpriteComponent;
import feint.library.HitboxComponent;
import feint.library.PositionComponent;

typedef Rect = {
  var x:Int;
  var y:Int;
  var width:Int;
  var height:Int;
  var color:Int;
  var rotation:Float;
}

class SandboxScene extends Scene {
  var forge:Forge;
  var rects:Array<Rect>;
  var rot:Float = 0;

  override function init() {
    super.init();

    camera.translation = {x: 40, y: 40};

    rects = [
      for (i in 0...100)
        {
          x: Math.floor(Math.random() * game.window.width),
          y: Math.floor(Math.random() * game.window.height),
          width: Math.floor(Math.random() * game.window.width / 4),
          height: Math.floor(Math.random() * game.window.height / 4),
          rotation: 0,
          color: 0xFF000000 | (Math.floor(
            Math.random() * 0xFF
          ) << 16) | (Math.floor(Math.random() * 0xFF) << 8) | Math.floor(Math.random() * 0xFF)
        }
    ];
    rects.sort((a, b) -> a.y - b.y);
    rects.push({
      x: 100,
      y: 100,
      width: 100,
      height: 100,
      rotation: Math.PI * 0.25,
      color: 0xFF00FFFF
    });
    rects.push({
      x: 250,
      y: 100,
      width: 100,
      height: 100,
      rotation: Math.PI * -0.15,
      color: 0xFFFF00FF
    });
    rects.push({
      x: 400,
      y: 100,
      width: 100,
      height: 100,
      rotation: Math.PI * Math.random(),
      color: 0xFFFFFF00
    });

    var sprite = new Sprite(Assets.platformer_character__png);
    sprite.textureWidth = 384;
    sprite.textureHeight = 192;
    sprite.setupSpriteSheetAnimation(96, 96, ['idle' => [0], 'jump' => [1], 'run' => [2, 3]]);
    sprite.animation.play('run', 30, true);

    forge = new Forge();
    forge.addEntity(Entity.create(), [
      new PositionComponent(0, 0),
      new HitboxComponent(0, 0, 96, 96),
      new SpriteComponent(sprite)
    ]);
    forge.addSystem(new SpriteAnimationSystem());
    forge.addRenderSystem(new SpriteRenderSystem());
  }

  override function update(elapsed:Float) {
    super.update(elapsed);

    forge.update(elapsed);

    rot += elapsed / 3000;
    if (rot >= 2) {
      rot = -2;
    }

    if (game.window.inputManager.keyboard.keys[KeyCode.W] == Pressed) {
      camera.translation = {
        x: camera.translation.x,
        y: camera.translation.y - (elapsed * 0.25)
      };
    } else if (game.window.inputManager.keyboard.keys[KeyCode.S] == Pressed) {
      camera.translation = {
        x: camera.translation.x,
        y: camera.translation.y + (elapsed * 0.25)
      };
    } else if (game.window.inputManager.keyboard.keys[KeyCode.A] == Pressed) {
      camera.translation = {
        x: camera.translation.x - (elapsed * 0.25),
        y: camera.translation.y
      };
    } else if (game.window.inputManager.keyboard.keys[KeyCode.D] == Pressed) {
      camera.translation = {
        x: camera.translation.x + (elapsed * 0.25),
        y: camera.translation.y
      };
    }

    if (game.window.inputManager.keyboard.keys[KeyCode.E] == Pressed) {
      camera.rotation -= elapsed * 0.001;
      if (camera.rotation <= -2 * Math.PI) {
        camera.rotation += 2 * Math.PI;
      }
    } else if (game.window.inputManager.keyboard.keys[KeyCode.Q] == Pressed) {
      camera.rotation += elapsed * 0.001;
      if (camera.rotation >= 2 * Math.PI) {
        camera.rotation += -2 * Math.PI;
      }
    }

    if (game.window.inputManager.keyboard.keys[KeyCode.Up] == Pressed) {
      camera.scale += elapsed * 0.005;
    } else if (game.window.inputManager.keyboard.keys[KeyCode.Down] == Pressed) {
      camera.scale -= elapsed * 0.005;
    }
  }

  override function render(renderer:Renderer) {
    super.render(renderer);
    renderer.drawRect(50, 50, 100, 100, 0, 0xFF00FFFF);
    renderer.drawRect(200, 200, 100, 100, 0, 0xFFFF0000);
    for (rect in rects) {
      renderer.drawRect(rect.x, rect.y, rect.width, rect.height, rect.rotation, rect.color);

      renderer.drawImage(rect.x + 100, rect.y + 100, Assets.icon__png, 512, 512, 0, 0.25, {
        x: 0,
        y: 0,
        width: 512,
        height: 512
      });

      renderer.drawImage(
        rect.x + 100,
        rect.y + 100,
        Assets.inwave_labs_discord__png,
        512,
        512,
        0,
        0.25,
        {
          x: 0,
          y: 0,
          width: 512,
          height: 512
        }
      );
    }

    renderer.drawRect(150, 150, 40, 40, Math.PI * rot, 0x550000FF);

    renderer.drawImage(250, 250, Assets.icon__png, 512, 512, Math.PI * 0.01, 1, {
      x: 128,
      y: 128,
      width: 128,
      height: 128
    });

    // renderer.drawText(0, 0, "Sandbox", 32, "sans-serif");

    forge.render(renderer);
  }
}
