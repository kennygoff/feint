package feint;

import feint.renderer.RenderContext;
import feint.renderer.platforms.WebRenderPlatform;
import feint.input.InputManager;
import feint.renderer.RenderContext;

/**
 * A Feint Window manages a context to render graphics and an input manager to
 * handle input events and devices.
 *
 * `Application` creates a window on start and that is the primary and only
 * window registered throughout the lifecycle of the application. The `Game`
 * instance also keeps a reference to the primary `Window` instance in
 * `Game.window` and that is the primary place it should be accessed.
 *
 * **Note:** Currently only one window is supported, but in the future there
 * may be support added to create additional windows. This will always refer
 * to the main default window.
 */
class Window {
  /**
   * Title of the window
   *
   * **Currently unused**
   *
   * **Note:** In web platforms, the title is the title of the HTML page that
   * is shown in the browser tab/window.
   */
  public var title(default, null):String;

  /**
   * Width in pixels of the window's renderable context, excluding platform
   * components like title bars and borders
   */
  public var width(default, null):Int;

  /**
   * Width in pixels of the window's renderable context, excluding platform
   * components like title bars and borders
   */
  public var height(default, null):Int;

  /**
   * Context to render all visual elements in the window. The context is
   * platform and backend specific.
   */
  public var renderContext(default, null):RenderContext;

  /**
   * Application-wide input manager that handles all input events and device
   * management.
   */
  public var inputManager(default, null):InputManager;

  /**
   * Create the window with the given settings, initialize the
   * `Window.renderContext`, and create the `Window.inputManager`.
   * @param title Application title (**Currently unused**)
   * @param width Width of the window's render context
   * @param height Height of the window's render context
   */
  public function new(title:String, width:Int, height:Int, api:RenderAPI = WebGL) {
    this.title = title;
    this.width = width;
    this.height = height;

    #if js
    renderContext = WebRenderPlatform.createContext(width, height, api);
    #else
    throw new FeintException(
      'NotImplemented',
      'Render Context for non-js targets are not implemented'
    );
    #end
    // TODO: Come up with a better way to manage render and input than passing around the render context
    inputManager = new InputManager(renderContext);
  }
}
