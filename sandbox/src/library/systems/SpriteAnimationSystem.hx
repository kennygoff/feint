package library.systems;

import feint.forge.Entity.EntityId;
import feint.forge.Forge;
import library.components.SpriteComponent;
import feint.forge.System;

private typedef Shape = {
  id:EntityId,
  sprite:SpriteComponent
}

class SpriteAnimationSystem extends System {
  public function new() {}

  override function update(elapsed:Float, forge:Forge) {
    var sprites:Array<Shape> = cast forge.getShapes([SpriteComponent]);

    var animatedSprites = sprites.filter(sprite -> sprite.sprite.sprite.animation != null);
    for (animatedSprite in animatedSprites) {
      if (!Math.isNaN(elapsed)) {
        animatedSprite.sprite.sprite.animation.update(elapsed);
      }
    }
  }
}
