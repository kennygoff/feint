package feint.renderer.backends;

import haxe.crypto.Base64;
import js.html.Image;
import js.html.ImageElement;
import feint.assets.macros.AssetEmbed;
import feint.debug.FeintException;
import js.html.CanvasElement;
import js.html.CanvasRenderingContext2D;
import feint.renderer.Renderer.TextureClip;
import feint.renderer.Renderer.TextAlign;
import feint.renderer.Renderer.RendererPrimitiveOptions;
import feint.renderer.RenderContext.RenderAPI;

class CanvasRenderContext implements RenderContext {
  public var api(default, null):RenderAPI;
  public var width(default, null):Int;
  public var height(default, null):Int;
  public var camera:Camera;

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
    drawRect(0, 0, canvas.width, canvas.height, 0, color);
    context.rotate(0);
  }

  public function submit() {
    // no-op
  }

  public function resize(width:Int, height:Int) {
    throw new FeintException(
      'NotImplemented',
      "RenderContext.resize() not implemented for Canvas"
    );
  }

  public function drawRect(
    x:Int,
    y:Int,
    width:Int,
    height:Int,
    rotation:Float = 0.0,
    color:Int = 0xFFFFFFFF,
    alpha:Float = 1.0,
    depth:Float = 1.0
  ) {
    // final fillColor = options != null ? options.color : null;
    // final strokeColor = options != null ? options.stroke : null;
    // final strokeWidth = options != null && options.strokeWidth != null ? options.strokeWidth : 1;

    if (camera != null) {
      context.setTransform(
        camera.scale,
        0,
        0,
        camera.scale,
        camera.translation.x,
        camera.translation.y
      );
      context.rotate(camera.rotation);
    }
    // context.lineWidth = strokeWidth;
    context.translate(x, y);
    context.translate(width / 2, height / 2);
    context.rotate(rotation);
    context.translate(-width / 2, -height / 2);
    // context.strokeStyle = colorToRGBA(strokeColor);
    context.fillStyle = colorToRGBA(color);
    context.fillRect(0, 0, width, height);
    // context.strokeRect(0, 0, width, height);
    context.setTransform(1, 0, 0, 1, 0, 0);
  }

  public function drawImage(
    x:Int,
    y:Int,
    assetId:String,
    textureWidth:Int,
    textureHeight:Int,
    rotation:Float = 0,
    scale:Float = 1,
    color:Int = 0xFFFFFFFF,
    alpha:Float = 1.0,
    depth:Float = 1.0,
    ?clip:TextureClip
  ) {
    if (camera != null) {
      context.setTransform(
        camera.scale,
        0,
        0,
        camera.scale,
        camera.translation.x,
        camera.translation.y
      );
      context.rotate(camera.rotation);
    }

    var textureEmbedded = AssetEmbed.embeddedAssets.exists(assetId);
    var image:ImageElement;
    if (textureEmbedded) {
      image = new Image();
      var embeddedBytes = AssetEmbed.embeddedAssets.get(assetId);
      image.src = "data:image/png;base64," + Base64.encode(embeddedBytes);
    } else {
      image = cast js.Browser.document.getElementById(assetId);
    }

    context.translate(x, y);
    context.rotate(rotation);
    if (clip != null) {
      if (scale != null) {
        context.drawImage(
          image,
          clip.x,
          clip.y,
          clip.width,
          clip.height,
          0,
          0,
          clip.width * scale,
          clip.height * scale
        );
      } else {
        context.drawImage(
          image,
          clip.x,
          clip.y,
          clip.width,
          clip.height,
          0,
          0,
          clip.width,
          clip.height
        );
      }
    } else {
      context.drawImage(image, 0, 0);
    }
    context.setTransform(1, 0, 0, 1, 0, 0);
  }

  public function drawText(x:Int, y:Int, text:String, fontSize:Int, font:String, align:TextAlign) {
    if (camera != null) {
      context.setTransform(
        camera.scale,
        0,
        0,
        camera.scale,
        camera.translation.x,
        camera.translation.y
      );
      context.rotate(2 * Math.PI - camera.rotation);
    }

    context.rotate(0);
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
