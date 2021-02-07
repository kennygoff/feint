package feint.renderer.platforms;

import feint.renderer.backends.CanvasRenderContext;
import feint.renderer.backends.WebGLRenderContext;
import feint.debug.FeintException;
import feint.debug.Logger;
import js.html.CanvasElement;
import feint.renderer.RenderContext.RenderAPI;

/**
 * Render platform that manages and creates the context for a Feint
 * application on the Javascript target.
 *
 * Defaults to WebGL with a Canvas fallback.
 */
class WebRenderPlatform {
  /**
   * Create a new render context based with a preferred API.
   *
   * Available API options:
   *
   * - `RenderAPI.WebGL2`: Not yet supported, please use `RenderAPI.WebGL`
   * - `RenderAPI.WebGL` (default): Attempts to use WebGL API, will fallback
   * to Canvas if WebGL is not supported
   * - `RenderAPI.Canvas`: Attempts to use Canvas, will show an error if
   * unsupported
   *
   * @param width Width of the viewport
   * @param height Height of the viewport
   * @param api Preferred Web render API
   * @return RenderContext
   */
  public static function createContext(
    width:Int,
    height:Int,
    api:RenderAPI = WebGL
  ):RenderContext {
    // Create canvas, which will be used regarless of Render API
    var canvas = createCanvasElement(width, height);

    switch (api) {
      case WebGL2:
        throw new FeintException('NotImplemented', 'WebGL2RenderContext not implemented...');
      case WebGL:
        Logger.info('Creating WebGL RenderContext...');
        var webglContext = canvas.getContext('webgl', {alpha: false});
        if (webglContext == null) {
          Logger.info('WebGL not supported, falling back to Canvas.');
          webglContext = null;
          Logger.info('Creating Canvas RenderContext...');
          var canvasContext = canvas.getContext('2d', {alpha: false});
          return new CanvasRenderContext(canvas, canvasContext, width, height);
        } else {
          return new WebGLRenderContext(canvas, webglContext, width, height);
        }
      case Canvas:
        Logger.info('Creating Canvas RenderContext...');
        var canvasContext = canvas.getContext('2d', {alpha: false});
        return new CanvasRenderContext(canvas, canvasContext, width, height);
    }

    throw new FeintException('NotImplemented', 'WebGLRenderContext not implemented...');
    return null;
  }

  static function createCanvasElement(width:Int, height:Int):CanvasElement {
    var canvas = js.Browser.document.createCanvasElement();
    canvas.id = 'feint';
    canvas.width = Std.int(width);
    canvas.height = Std.int(height);
    canvas.textContent = '[Feint] This browser is not supported';
    js.Browser.document.body.appendChild(canvas);
    return canvas;
  }
}
