package feint.renderer;

import feint.renderer.Renderer.TextAlign;
import feint.renderer.Renderer.RendererPrimitiveOptions;
import feint.renderer.Renderer.TextureClip;
import js.html.CanvasRenderingContext2D;
import js.html.CanvasElement;
import feint.debug.FeintException;
import feint.debug.Logger;

#if js
enum RenderWebAPI {
  Canvas;
  WebGL;
  WebGL2;
}
#end

class RenderContext {
  #if js
  var webAPI:RenderWebAPI;
  var webCanvas:CanvasElement;
  var webContext:CanvasRenderingContext2D;
  #end
  var width:Int;
  var height:Int;

  public function new(width:Int, height:Int) {
    this.width = width;
    this.height = height;
    #if js
    this.webAPI = Canvas;
    #end

    createContext();
  }

  public function clear() {
    #if js
    webContext.clearRect(0, 0, webCanvas.width, webCanvas.height);
    #else
    throw new FeintException('NotImplemented', 'Not implemented.');
    #end
  }

  public function drawRect(
    x:Int,
    y:Int,
    width:Int,
    height:Int,
    ?options:RendererPrimitiveOptions
  ) {
    #if js
    final fillColor = options != null ? options.color : null;
    final strokeColor = options != null ? options.stroke : null;
    final strokeWidth = options != null && options.strokeWidth != null ? options.strokeWidth : 1;

    webContext.lineWidth = strokeWidth;
    webContext.strokeStyle = colorToRGBA(strokeColor);
    webContext.fillStyle = colorToRGBA(fillColor);
    webContext.fillRect(x, y, width, height);
    webContext.strokeRect(x, y, width, height);
    #else
    throw new FeintException('NotImplemented', 'Not implemented.');
    #end
  }

  public function drawText(x:Int, y:Int, text:String, fontSize:Int, font:String, align:TextAlign) {
    #if js
    webContext.textAlign = align;
    webContext.fillStyle = colorToRGBA(0xFFFFFFFF);
    webContext.font = '${fontSize}px ${font}';
    webContext.textBaseline = 'top';
    webContext.fillText(text, x, y);
    #else
    throw new FeintException('NotImplemented', 'Not implemented.');
    #end
  }

  public function drawImage(x:Int, y:Int, assetId:String, ?clip:TextureClip, ?scale:Float) {
    #if js
    if (clip != null) {
      if (scale != null) {
        webContext.drawImage(
          cast js.Browser.document.getElementById(assetId),
          clip.x,
          clip.y,
          clip.width,
          clip.height,
          x,
          y,
          clip.width * scale,
          clip.height * scale
        );
      } else {
        webContext.drawImage(
          cast js.Browser.document.getElementById(assetId),
          clip.x,
          clip.y,
          clip.width,
          clip.height,
          x,
          y,
          clip.width,
          clip.height
        );
      }
    } else {
      webContext.drawImage(cast js.Browser.document.getElementById(assetId), x, y);
    }
    #else
    throw new FeintException('NotImplemented', 'Not implemented.');
    #end
  }

  #if js
  function createContext() {
    Logger.info('Creating RenderContext...');

    // Create Canvas
    webCanvas = js.Browser.document.createCanvasElement();
    webCanvas.id = 'feint';
    webCanvas.width = Std.int(width);
    webCanvas.height = Std.int(height);
    webCanvas.textContent = '[Feint] This browser is not supported';
    js.Browser.document.body.appendChild(webCanvas);

    // Create Canvas 2D Context
    webContext = webCanvas.getContext('2d', {alpha: false});

    // Handle High DPI screens
    // Fixes font scaling issues on high DPI monitors without changing the actual canvas size
    webCanvas.width = Math.floor(width * js.Browser.window.devicePixelRatio);
    webCanvas.height = Math.floor(height * js.Browser.window.devicePixelRatio);
    webCanvas.style.width = width + 'px';
    webCanvas.style.height = height + 'px';
    webContext.scale(js.Browser.window.devicePixelRatio, js.Browser.window.devicePixelRatio);

    // Disable smoothing
    webContext.imageSmoothingEnabled = false;

    Logger.info('Created RenderContext using ${webAPI} API');
  }
  #else
  function createContext() {
    Logger.error('This platform is not supported.');
    throw new FeintException(
      'PlatformNotSupported',
      'Error creating a RenderContext! This platform is not supported.The currently supported platform is js.'
    );
  }
  #end

  static inline function colorToRGBA(color:Int):String {
    final alpha = ((color >> 24) & 0xFF) / 255;
    final red = (color >> 16) & 0xFF;
    final green = (color >> 8) & 0xFF;
    final blue = color & 0xFF;

    return 'rgba(${red}, ${green}, ${blue}, ${alpha})';
  }
}
