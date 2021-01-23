package feint;

import feint.renderer.RenderContext.RenderAPI;
import feint.debug.Logger;
import feint.debug.FeintException;
import feint.renderer.Renderer;

/**
 * Settings used to determine Application startup details
 */
typedef ApplicationSettings = {
  /**
   * Title of the application for the window title bar and browser window
   *
   * **Note:** Currently unused in web builds, use the compiler flag
   * `-D feint:appTitle=Your App Title`
   */
  // TODO: Title not used by AssetBuilder, so won't actually show up in the title bar.
  var title:String;

  /**
   * Initial window size
   *
   * **Note:** In the web platform, the size of the application refers to the
   * size of the canvas that the game is drawn to.
   */
  var size:{
    var width:Int;
    var height:Int;
  };

  /**
   * Specify a particular Render API to use.
   *
   * JS target defaults to `RenderAPI.Canvas`.
   */
  var ?api:RenderAPI;
}

/**
 * Point of entry for all Feint games that handles application setup, render
 * context, and game initialization.
 *
 * Only one Application can be instantiated at once. Extend this class as your
 * game's main entry class, and create a new instance in the `main` function
 * to setup a new Feint Application.
 *
 * ```haxe
 * class MyGame extends Application {
 *   static public function main() {
 *     new MyGame({
 *       title: "My Awesome Feint Game",
 *       size: {
 *         width: 640,
 *         height: 360
 *       }
 *     });
 *   }
 * }
 * ```
 */
class Application {
  /**
   * Main window of the application, created on startup.
   *
   * **Note:** Currently only one window is supported, but in the future there
   * may be support added to create additional windows. This will always refer
   * to the main default window.
   */
  @:dox(show)
  var window:Window;

  /**
   * Main game object that handles all game-specific logic and rendering.
   */
  @:dox(show)
  var game:Game;

  /**
   * Main renderer of the application attached to the `renderer.RenderContext`
   * of the default `Window`, created on startup.
   *
   * **Note:** Currently only one window is supported, but in the future there
   * may be support added to create additional windows. This will always refer
   * to the main default window's renderer.
   */
  @:dox(show)
  var renderer:Renderer;

  /**
   * Static instance of the application, used to check and enforce we only have
   * one instance created.
   */
  static var application:Application;

  /**
   * Timestamp of the start of the application. Primarily used for fps
   * calculation and debugging.
   */
  var startTimestamp(default, null):Float;

  /**
   * Timestamp of the last frame we processed, used to calulate elapsed time.
   */
  var lastFrameTimestamp(default, null):Float = 0;

  /**
   * Number of frames that have been processed since the application has
   * started. Primarily used for fps calculation and debugging.
   */
  var framesProcessed(default, null):Int;

  /**
   * Rolling average FPS
   */
  public var fps(default, null):Float;

  /**
   * Average FPS for the entire lifetime of the application
   */
  public var lifetimeFPS(default, null):Float;

  /**
   * Creates a Feint Application, initializes a `Window` and `Game`, and starts
   * the first frame
   * @param settings Settings used by Application to start up application and
   * window
   */
  @:dox(show)
  function new(settings:ApplicationSettings) {
    if (application != null) {
      throw new FeintException(
        'ApplicationAlreadyCreated',
        'Only one Application can run at the same time.'
      );
    }

    Logger.info('Application starting...');
    setup(settings);
    init();
    start();
  }

  /**
   * Initialization function for doing setup before the game starts. Is run
   * after the `Window` and `Game` are created but before the first frame starts.
   *
   * Override this function in your game to run code that has to be run before
   * the initial frame. Typically used to register the initial `Scene` for the
   * game.
   *
   * ```haxe
   * override public function init() {
   *   game.setInitialScene(new MyGameScene());
   * }
   * ```
   */
  public function init() {}

  /**
   * Initial setup of application `Window`, `renderer.Renderer`, and `Game`.
   *
   * **WARNING:** Do not override, used internally by Application only.
   * @param settings Settings used by Application to startup application and window
   */
  function setup(settings:ApplicationSettings) {
    window = new Window(settings.title, settings.size.width, settings.size.height, settings.api);
    renderer = new Renderer(window.renderContext);
    game = new Game(renderer, window);
    @:privateAccess(Game)
    game.application = this;
  }

  /**
   * Main update function that controls the core game loop.
   *
   * **WARNING:** Do not override, used internally by Application only.
   * @param elapsed [milliseconds] Amount of time elapsed in this update frame,
   * currently locked to monitor framerate
   */
  function update(elapsed:Float) {
    window.inputManager.update(elapsed);
    game.update(elapsed);
  }

  /**
   * Main render function executed on each frame after update.
   *
   * **WARNING:** Do not override, used internally by Application only.
   * @param renderer Default renderer used by Feint for this application's window
   */
  function render(renderer:Renderer) {
    game.render();
  }

  /**
   * Starting point for the game and game loop, fires off first frame request.
   *
   * **WARNING:** Do not override, used internally by Application only.
   */
  function start() {
    requestFirstFrame();
  }

  /**
   * Setup frame requests, first frame request takes some time and is choppy so
   * let it stabilize
   *
   * **WARNING:** Do not override, used internally by Application only.
   */
  function requestFirstFrame() {
    #if js
    framesProcessed = 0;
    startTimestamp = 0;
    lifetimeFPS = 0;
    fps = 0;
    js.Browser.window.requestAnimationFrame((timestamp:Float) -> {
      lastFrameTimestamp = timestamp;
      framesProcessed = 0;
      fps = 0;
      lifetimeFPS = 0;
      startTimestamp = timestamp;
      requestFrame();
    });
    #else
    Logger.error('This platform is not supported.');
    throw new FeintException(
      'PlatformNotSupported',
      'Error running Application.start()! This platform is not supported. The currently supported platform is js.'
    );
    #end
  }

  /**
   * Trigger for starting each frame event
   *
   * **WARNING:** Do not override, used internally by Application only.
   */
  function requestFrame() {
    #if js
    js.Browser.window.requestAnimationFrame(onFrame);
    #else
    Logger.error('This platform is not supported.');
    throw new FeintException(
      'PlatformNotSupported',
      'Error running Application.start()! This platform is not supported. The currently supported platform is js.'
    );
    #end
  }

  /**
   * Frame callback function that handles the core game loop
   *
   * The flow of each loop goes through the following steps:
   *
   * 1. Calculate elapsed time since last frame
   * 2. Update
   * 3. Render
   * 4. Request next frame
   *
   * **WARNING:** Do not override, used internally by Application only.
   * @param timestamp [milliseconds] Current time in seconds
   */
  function onFrame(timestamp:Float) {
    framesProcessed++;
    var elapsed = timestamp - lastFrameTimestamp;
    lastFrameTimestamp = timestamp;
    lifetimeFPS = 1000 * framesProcessed / (timestamp - startTimestamp);
    fps = (0.95 * fps) + (0.05 * (1000 / elapsed));
    update(elapsed);
    render(renderer);

    requestFrame();
  }
}
