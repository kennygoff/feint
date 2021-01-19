package feint.renderer.backends;

import feint.debug.FeintException;
import js.html.CanvasElement;
import js.html.CanvasRenderingContext2D;
import feint.renderer.Renderer.TextureClip;
import feint.renderer.Renderer.TextAlign;
import feint.renderer.Renderer.RendererPrimitiveOptions;
import feint.renderer.RenderContext.RenderAPI;

class CanvasRenderContext implements RenderContext2D {
  public var api(default, null):RenderAPI;
  public var width(default, null):Int;
  public var height(default, null):Int;

  var canvas:CanvasElement;
  var context:CanvasRenderingContext2D;

  public function new(
    canvas:CanvasElement,
    context:CanvasRenderingContext2D,
    width:Int,
    height:Int
  ) {
    this.width = width;
    this.height = height;
    this.api = Canvas;
    this.canvas = canvas;
    this.context = context;
    setup();
  }

  function setup() {
    // Handle High DPI screens
    // Fixes font scaling issues on high DPI monitors without changing the actual canvas size
    canvas.width = Math.floor(width * js.Browser.window.devicePixelRatio);
    canvas.height = Math.floor(height * js.Browser.window.devicePixelRatio);
    canvas.style.width = width + 'px';
    canvas.style.height = height + 'px';
    context.scale(js.Browser.window.devicePixelRatio, js.Browser.window.devicePixelRatio);

    // Disable smoothing
    context.imageSmoothingEnabled = false;
  }

  public function clear(color:Int = 0xFF000000) {
    context.clearRect(0, 0, canvas.width, canvas.height);
    drawRect(0, 0, canvas.width, canvas.height, {color: color});
  }

  public function resize(width:Int, height:Int) {
    throw new FeintException(
      'NotImplemented',
      "RenderContext2D.resize() not implemented for Canvas"
    );
  }

  public function drawRect(
    x:Int,
    y:Int,
    width:Int,
    height:Int,
    ?options:RendererPrimitiveOptions
  ) {
    final fillColor = options != null ? options.color : null;
    final strokeColor = options != null ? options.stroke : null;
    final strokeWidth = options != null && options.strokeWidth != null ? options.strokeWidth : 1;

    context.lineWidth = strokeWidth;
    context.strokeStyle = colorToRGBA(strokeColor);
    context.fillStyle = colorToRGBA(fillColor);
    context.fillRect(x, y, width, height);
    context.strokeRect(x, y, width, height);
  }

  public function drawImage(x:Int, y:Int, assetId:String, ?clip:TextureClip, ?scale:Float) {
    if (clip != null) {
      if (scale != null) {
        context.drawImage(
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
        context.drawImage(
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
      context.drawImage(cast js.Browser.document.getElementById(assetId), x, y);
    }
  }

  public function drawText(x:Int, y:Int, text:String, fontSize:Int, font:String, align:TextAlign) {
    context.textAlign = align;
    context.fillStyle = colorToRGBA(0xFFFFFFFF);
    context.font = '${fontSize}px ${font}';
    context.textBaseline = 'top';
    context.fillText(text, x, y);
  }

  static inline function colorToRGBA(color:Int):String {
    final alpha = ((color >> 24) & 0xFF) / 255;
    final red = (color >> 16) & 0xFF;
    final green = (color >> 8) & 0xFF;
    final blue = color & 0xFF;

    return 'rgba(${red}, ${green}, ${blue}, ${alpha})';
  }
}
