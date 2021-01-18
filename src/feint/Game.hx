package feint;

import feint.debug.Logger;
import feint.scene.Scene;
import feint.renderer.Renderer;

/**
 * Main game object in Feint that manages the core game loop and scenes. Each
 * Feint `Application` creates and manages a single instance of `Game`.
 *
 * The primary way you interact `Game` is to assign scenes and dispatch scene
 * changes. It's essentially a glorified scene manager. Each scene managed by
 * a game will also have a reference to the game in `Scene.game`.
 *
 * Under the hood, `Game` will coordinate with the `Application` to also keep
 * the core loop running and updates and renders going. This is managed
 * internally and shouldn't need intervention in order to setup game-specific
 * logic and rendering.
 */
class Game {
  /**
   * Currently active scene used in the main game loop to update and render
   */
  public var activeScene(default, null):Scene;

  /**
   * Queued next scene, as requested by the current scene. Will become the
   * current scene after the current frame is finished processing.
   */
  public var nextScene(default, null):Scene;

  /**
   * Primary window this game operates in for both updates and renders.
   */
  public var window(default, null):Window;

  /**
   * Rough FPS calculation based on the last frame time.
   * <p>
   *   **Note:** Not an average! This is simply the time since the last frame
   *   in the FPS format.
   * </p>
   */
  // TODO: Frame info
  // TODO: Deterministic semi-fixed frame rate https://gafferongames.com/post/fix_your_timestep/
  public var fps(default, null):Int;

  /**
   * [milliseconds] Amount of time passed since the last frame was processed.
   */
  public var frameTime(default, null):Float;

  /**
   * Renderer used in the render call every frame, attached to the window's
   * `renderer.RenderContext`.
   */
  @:dox(show)
  var renderer:Renderer;

  /**
   * Sets the renderer and window.
   * @param renderer Renderer the game will render to, attached to the given
   * window's `Window.renderContext`
   * @param window Window the game will be attached to
   */
  public function new(renderer:Renderer, window:Window) {
    this.renderer = renderer;
    this.window = window;
  }

  /**
   * Core update function, called in the main game loop.
   *
   * Update flow:
   *
   * 1. Switch to queued scene, if one was queued last frame
   * 2. Update frame timers
   * 3. Call update for `Game.activeScene`
   */
  public function update(elapsed:Float) {
    // Always swap to nextScene before continuing with any updates
    // TODO: Consider moving to a preupdate function
    if (nextScene != null) {
      Logger.info('Switching to scene: ${Type.getClassName(Type.getClass(nextScene))}');
      activeScene = nextScene;
      nextScene = null;
    }

    frameTime = elapsed;
    fps = Math.round(1000 / frameTime);

    if (activeScene != null) {
      activeScene.update(elapsed);
    }
  }

  /**
   * Core render function, called in the main game loop.
   *
   * Render flow:
   *
   * 1. Clear context
   * 2. Draw black background
   * 3. Call render for `Game.activeScene`
   */
  public function render() {
    renderer.clear();

    renderer.drawRect(0, 0, window.width, window.height, {color: 0xFF000000});

    if (activeScene != null) {
      activeScene.render(renderer);
    }
  }

  /**
   * Set the initial game scene to a given `Scene` and calls `Scene.init`
   * @param scene Starting scene
   * @return Reference to the new `Game.activeScene`
   */
  public function setInitialScene(scene:Scene):Scene {
    Logger.info('Initializing game with scene: ${Type.getClassName(Type.getClass(scene))}');
    activeScene = scene;
    @:privateAccess(Scene)
    activeScene.game = this;
    activeScene.init();
    return activeScene;
  }

  /**
   * Change the active game scene to a different scene. Scene change occurs
   * after current frame finishes updating.
   * @param scene New scene to change to
   * @return Reference to the current `Game.activeScene`
   */
  public function changeScene(scene:Scene):Scene {
    Logger.info('Requesting scene change: ${Type.getClassName(Type.getClass(scene))}');
    nextScene = scene;
    @:privateAccess(Scene)
    nextScene.game = this;
    nextScene.init();
    return activeScene;
  }
}
