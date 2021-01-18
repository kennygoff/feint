package feint;

import feint.scene.Scene;
import feint.renderer.Renderer;

class Game {
  public var activeScene(default, null):Scene;
  public var nextScene(default, null):Scene;
  public var window(default, null):Window;

  // TODO: Frame info
  // TODO: Deterministic semi-fixed frame rate https://gafferongames.com/post/fix_your_timestep/
  public var fps(default, null):Int;
  public var frameTime(default, null):Float;

  var renderer:Renderer;

  public function new(renderer:Renderer) {
    this.renderer = renderer;
  }

  public function update(elapsed:Float) {
    // Always swap to nextScene before continuing with any updates
    // TODO: Consider moving to a preupdate function
    if (nextScene != null) {
      activeScene = nextScene;
      nextScene = null;
    }

    frameTime = elapsed;
    fps = Math.round(1000 / frameTime);

    if (activeScene != null) {
      activeScene.update(elapsed);
    }
  }

  public function render() {
    renderer.clear();

    renderer.drawRect(0, 0, window.width, window.height, {color: 0xFF000000});

    if (activeScene != null) {
      activeScene.render(renderer);
    }
  }

  /**
   * Set the initial game scene to a new scene
   * @param scene Starting scene
   * @return Scene
   */
  public function setInitialScene(scene:Scene):Scene {
    activeScene = scene;
    @:privateAccess(Scene)
    activeScene.game = this;
    activeScene.init();
    return activeScene;
  }

  /**
   * Change the current game scene to a different scene. Scene change occurs after current frame finishes updating.
   * @param scene New scene to change to
   * @return Scene
   */
  public function changeScene(scene:Scene):Scene {
    nextScene = scene;
    @:privateAccess(Scene)
    nextScene.game = this;
    nextScene.init();
    return activeScene;
  }
}
