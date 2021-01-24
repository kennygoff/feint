package feint;

import feint.input.device.Keyboard.KeyCode;
import feint.renderer.backends.WebGLRenderContext;
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
   * Reference to the global application this game runs in.
   */
  public var application(default, null):Application;

  /**
   * Average fps, rounded to nearest integer.
   *
   * @deprecated Use application.fps directly
   */
  // TODO: Frame info
  // TODO: Deterministic semi-fixed frame rate https://gafferongames.com/post/fix_your_timestep/
  public var fps(get, null):Int;

  /**
   * [milliseconds] Amount of time passed since the last frame was processed.
   */
  public var frameElapsed(default, null):Float;

  /**
   * Amount of time it took to update this frame.
   */
  public var frameUpdateTime(default, null):Float = 0;

  /**
   * Amount of time it took to render this frame.
   */
  public var frameRenderTime(default, null):Float = 0;

  /**
   * Toggle to show debug UI with backtick `\``
   */
  var showDebugUI:Bool = false;

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
    #if debug
    var updateTime = Date.now().getTime();
    #end

    // Always swap to nextScene before continuing with any updates
    // TODO: Consider moving to a preupdate function
    if (nextScene != null) {
      Logger.info('Switching to scene: ${Type.getClassName(Type.getClass(nextScene))}');
      activeScene = nextScene;
      nextScene = null;
    }

    frameElapsed = elapsed;

    if (activeScene != null) {
      activeScene.update(elapsed);
    }

    #if debug
    if (window.inputManager.keyboard.keys[KeyCode.Backtick] == JustPressed) {
      showDebugUI = !showDebugUI;
    }
    frameUpdateTime = Date.now().getTime() - updateTime;
    #end
  }

  /**
   * Core render function, called in the main game loop.
   *
   * Render flow:
   *
   * 1. Clear context & draw black background
   * 2. Call render for `Game.activeScene`
   */
  public function render() {
    #if debug
    var renderTime = Date.now().getTime();
    #end

    renderer.clear();

    if (activeScene != null) {
      activeScene.render(renderer);
    }

    renderer.submit();

    #if debug
    frameRenderTime = Date.now().getTime() - renderTime;
    #end

    #if debug
    // TODO: Move to debug UI
    if (showDebugUI) {
      @:privateAccess(Renderer)
      if (renderer.renderContext.api == WebGL) {
        var webGLRenderContext:WebGLRenderContext = cast renderer.renderContext;
        @:privateAccess(WebGLRenderContext)
        webGLRenderContext.textRenderContext.drawRect(4, 4, 130, 62, {color: 0xBB000000});
      } else {
        renderer.drawRect(4, 4, 130, 62, {color: 0xBB000000});
      }

      renderer.drawText(8, 8 + 2, 'FPS: ${fps}', 16, 'sans-serif');
      renderer.drawText(8, 8 + 2 + (18 * 1), 'Update: ${frameUpdateTime}ms', 16, 'sans-serif');
      renderer.drawText(8, 8 + 2 + (18 * 2), 'Render: ${frameRenderTime}ms', 16, 'sans-serif');
    }
    #end
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

  /**
   * Get rounded fps value for simple display
   * @return Int
   *
   * @deprecated Use application.fps directly
   */
  public function get_fps():Int {
    return Math.round(application.fps);
  }
}
