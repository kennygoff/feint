package scenes;

import library.systems.SpriteRenderSystem;
import library.systems.SpriteAnimationSystem;
import library.components.SpriteComponent;
import library.components.HitboxComponent;
import library.components.PositionComponent;
import feint.forge.Entity;
import feint.forge.Forge;
import feint.graphics.Sprite;
import feint.assets.Assets;
import feint.renderer.Renderer;
import feint.scene.Scene;

typedef Rect = {
  var x:Int;
  var y:Int;
  var width:Int;
  var height:Int;
  var color:Int;
}

class SandboxScene extends Scene {
  var forge:Forge;
  var rects:Array<Rect>;

  override function init() {
    super.init();

    rects = [
      for (i in 0...3000)
        {
          x: Math.floor(Math.random() * game.window.width),
          y: Math.floor(Math.random() * game.window.height),
          width: Math.floor(Math.random() * game.window.width / 4),
          height: Math.floor(Math.random() * game.window.height / 4),
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
      color: 0xFF00FFFF
    });
    rects.push({
      x: 250,
      y: 100,
      width: 100,
      height: 100,
      color: 0xFFFF00FF
    });
    rects.push({
      x: 400,
      y: 100,
      width: 100,
      height: 100,
      color: 0xFFFFFF00
    });

    var sprite = new Sprite(Assets.platformer_character__png);
    sprite.textureWidth = 384;
    sprite.textureHeight = 192;
    sprite.setupSpriteSheetAnimation(96, 96, ['idle' => [0], 'jump' => [1], 'run' => [2, 3]]);
    sprite.animation.play('run', 30, true);

    forge = new Forge();
    // forge.addEntity(Entity.create(), [
    //   new PositionComponent(0, 0),
    //   new HitboxComponent(0, 0, 96, 96),
    //   new SpriteComponent(sprite)
    // ]);
    forge.addSystem(new SpriteAnimationSystem());
    forge.addRenderSystem(new SpriteRenderSystem());
  }

  override function update(elapsed:Float) {
    super.update(elapsed);

    forge.update(elapsed);
  }

  override function render(renderer:Renderer) {
    super.render(renderer);

    // renderer.drawImage(0, 0, Assets.icon__png, {
    //   x: 128,
    //   y: 128,
    //   width: 256,
    //   height: 256
    // }, 1, 512, 512);
    for (rect in rects) {
      renderer.drawRect(rect.x, rect.y, rect.width, rect.height, {color: rect.color});
    }
    // renderer.drawImage(100, 100, Assets.inwave_labs_discord__png, {
    //   x: 0,
    //   y: 0,
    //   width: 100,
    //   height: 100
    // });
    // renderer.drawImage(300, 200, Assets.icon__png, {
    //   x: 0,
    //   y: 0,
    //   width: 100,
    //   height: 100
    // });
    // renderer.drawText(0, 0, "Sandbox", 32, "sans-serif");

    forge.render(renderer);
  }
}
