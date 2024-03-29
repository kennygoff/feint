package feint.scene;

import feint.forge.Forge;
import feint.renderer.Camera;
import feint.renderer.Renderer;

/**
 * Base class for creating a Scene
 */
class Scene {
  /**
   * Reference to the scene's parent game.
   */
  var game:Game;

  /**
   * The main camera for the scene.
   */
  var camera:Camera;

  /**
   * Forge for this scene, managed and updated by the scene.
   */
  var forge:Forge;

  public function new() {
    camera = new Camera();
  }

  /**
   * Scene initialization: Override to setup scene, load assets, and start a
   * `Forge`.
   */
  public function init() {
    forge = new Forge();
  }

  /**
   * Scene update: Override to handle input, make regular game loop updates,
   * and update a `Forge`.
   * @param elapsed [milliseconds] Time since the last frame was processed
   */
  public function update(elapsed:Float) {
    forge.update(elapsed);
  }

  /**
   * Scene update: Override to submit render calls and render a `Forge`.
   * @param renderer
   */
  public function render(renderer:Renderer) {
    renderer.camera = camera;
    forge.render(renderer);
  }
}
