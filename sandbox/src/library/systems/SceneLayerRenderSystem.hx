package library.systems;

import feint.scene.Layer;
import feint.renderer.Renderer;
import feint.forge.Forge;
import feint.forge.System.RenderSystem;

class SceneLayerRenderSystem extends RenderSystem {
  public var layers:Array<Layer>;

  public function new(layers:Array<Layer>) {
    this.layers = layers;
  }

  override function render(renderer:Renderer, forge:Forge) {}
}
