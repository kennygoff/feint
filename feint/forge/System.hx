package feint.forge;

import feint.renderer.Renderer;
import feint.debug.FeintException;

class System {
  public function update(elapsed:Float, forge:Forge) {
    throw new FeintException(
      'ForgeSystemNotImplemented',
      'Forge System not implemented, make sure to override `update` and not call `super.update()`.'
    );
  }
}

class RenderSystem {
  public function render(renderer:Renderer, forge:Forge) {
    throw new FeintException(
      'ForgeRenderNotImplemented',
      'Forge RenderSystem not implemented, make sure to override `render` and not call `super.render()`.'
    );
  }
}
