package feint;

import feint.debug.FeintException;
import feint.debug.Logger;
import feint.renderer.Renderer;

/**
 * Settings used to determine Application startup details
 */
typedef ApplicationSettings = {
  /**
   * Title of the application
   */
  // TODO: Title not used by AssetBuilder, so won't actually show up in the title bar
  var title:String;

  /**
   * Initial window size
   *
   * > **Platform: Web**
   * >
   * > In the web platform, the size of the application refers to the size of
   * > the canvas that the game is drawn to.
   */
  var size:{
    var width:Int;
    var height:Int;
  };
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
  @:dox(hide)
  public static var application:Application;

  var lastTime:Float;
  var name:String;
  var window:Window;
  var game:Game;

  /**
   * Creates a Feint Application, initializes a `Window` and `Game`, and start the
   * first frame
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

    setup(settings);
    init();
    start();
  }

  /**
   * Initialization function for doing setup before the game starts. Is run
   * after the `Window` and `Game` are created but before the first frame starts.
   *
   * Override this function in your game to. Typically used to register the
   * initial `Scene` for the game.
   *
   * ```haxe
   * override function init() {
   *   game.setInitialScene(new MyGameScene());
   * }
   * ```
   */
  @:dox(show)
  function init() {}

  /**
   * Initial setup of application `Window`, `renderer.Renderer`, and `Game`.
   *
   * **WARNING:** Do not override, used internally by Application only.
   * @param settings Settings used by Application to startup application and window
   */
  function setup(settings:ApplicationSettings) {
    window = new Window(settings.title, settings.size.width, settings.size.height);

    var renderer = new Renderer(window.renderContext);
    game = new Game(renderer);
    @:privateAccess(Game)
    game.window = window;
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
    requestFrame();
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
    var elapsed = timestamp - lastTime;
    lastTime = timestamp;
    update(elapsed);
    @:privateAccess(Game)
    render(game.renderer);

    requestFrame();
  }
}
