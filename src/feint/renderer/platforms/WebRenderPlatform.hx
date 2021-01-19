package feint.renderer.platforms;

import feint.renderer.backends.CanvasRenderContext;
import feint.renderer.backends.WebGLRenderContext;
import feint.debug.FeintException;
import feint.debug.Logger;
import js.html.CanvasElement;
import feint.renderer.RenderContext.RenderAPI;

class WebRenderPlatform {
  public static function createContext(
    width:Int,
    height:Int,
    api:RenderAPI = Canvas
  ):RenderContext2D {
    // Create canvas, which will be used regarless of Render API
    var canvas = createCanvasElement(width, height);

    switch (api) {
      case WebGL2:
        throw new FeintException('NotImplemented', 'WebGL2RenderContext not implemented...');
      case WebGL:
        Logger.info('Creating WebGL RenderContext...');
        var webglContext = canvas.getContext('webgl');
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
