package feint.library;

import feint.forge.Entity.EntityId;
import feint.renderer.Renderer;
import feint.forge.Forge;
import feint.forge.System.RenderSystem;
import feint.library.PositionComponent;

private typedef Shape = {
  id:EntityId,
  position:PositionComponent,
  bitmapText:BitmapTextComponent
}

class BitmapTextRenderSystem extends RenderSystem {
  public function new() {}

  override function render(renderer:Renderer, forge:Forge) {
    var texts:Array<Shape> = cast forge.getShapes([BitmapTextComponent, PositionComponent]);

    for (text in texts) {
      text.bitmapText.text.draw(
        renderer,
        Math.floor(text.position.x),
        Math.floor(text.position.y),
        text.bitmapText.fontSize
      );
    }
  }
}
