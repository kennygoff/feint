package feint.library;

import feint.forge.Entity.EntityId;
import feint.renderer.Renderer;
import feint.forge.Forge;
import feint.forge.System.RenderSystem;
import feint.library.PositionComponent;
import feint.library.SpriteComponent;

private typedef Shape = {
  id:EntityId,
  sprite:SpriteComponent,
  position:PositionComponent
}

class SpriteRenderSystem extends RenderSystem {
  public function new() {}

  override function render(renderer:Renderer, forge:Forge) {
    var sprites:Array<Shape> = cast forge.getShapes([SpriteComponent, PositionComponent]);
    var visibleSprites = sprites.filter(sprite -> sprite.sprite.sprite.alpha > 0);

    for (sprite in visibleSprites) {
      sprite.sprite.sprite.drawAt(sprite.position.x, sprite.position.y, renderer);
    }
  }
}
