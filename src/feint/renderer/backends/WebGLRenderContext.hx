package feint.renderer.backends;

import feint.renderer.backends.BatchRenderWebGLShader;
import js.html.URL;
import js.html.ImageElement;
import js.html.Image;
import feint.debug.FeintException;
import js.lib.Float32Array;
import feint.debug.Logger;
import feint.renderer.Renderer.TextureClip;
import feint.renderer.Renderer.TextAlign;
import feint.renderer.Renderer.RendererPrimitiveOptions;
import js.html.webgl.RenderingContext;
import js.html.webgl.Program;
import js.html.webgl.Shader;
import js.html.CanvasElement;
import feint.renderer.RenderContext.RenderAPI;

enum abstract WebGLShaderType(Int) to Int {
  var Vertex = RenderingContext.VERTEX_SHADER;
  var Fragment = RenderingContext.FRAGMENT_SHADER;
}

class WebGLRenderContext implements RenderContext {
  public var api(default, null):RenderAPI;
  public var width(default, null):Int;
  public var height(default, null):Int;

  var canvas:CanvasElement;
  var context:RenderingContext;

  // Batch Renderer
  var batchRender:BatchRenderWebGLShader;
  var textures:Map<String, ImageElement>;
  var textureId:Map<String, Int>;
  var textureIndex:Array<String>; // TODO: Need an ordered map or something

  // TODO: Temp
  var textCanvas:CanvasElement;
  var textRenderContext:CanvasRenderContext;

  public function new(canvas:CanvasElement, context:RenderingContext, width:Int, height:Int) {
    this.width = width;
    this.height = height;
    this.api = WebGL;
    this.canvas = canvas;
    this.context = context;
    setup();
  }

  public function clear(color:Int = 0xFF000000) {
    // TODO: Resizing
    // See: https://webglfundamentals.org/webgl/lessons/webgl-resizing-the-canvas.html
    context.viewport(0, 0, context.canvas.width, context.canvas.height);
    context.clearColor(0, 0, 0, 1);
    context.clear(RenderingContext.COLOR_BUFFER_BIT);
    // context.pixelStorei(RenderingContext.UNPACK_PREMULTIPLY_ALPHA_WEBGL, 1);
    // context.blendFunc(RenderingContext.ONE, RenderingContext.ONE_MINUS_SRC_ALPHA);
    // context.blendFunc(RenderingContext.SRC_ALPHA, RenderingContext.ONE_MINUS_SRC_ALPHA);

    // TODO: Text solutions
    if (js.Browser.document.getElementById('feint-webgl-text') != null) {
      js.Browser.document.getElementById('feint-webgl-text').innerHTML = '';
    }
    if (textRenderContext != null) {
      // Not using clear() because we default to clearing with a black background
      // textRenderContext.clear();
      @:privateAccess(textRenderContext)
      textRenderContext.context.clearRect(0, 0, canvas.width, canvas.height);
    }

    // TODO: Figure out how to better store these frame-by-frame so we're not
    // rebuilding it each frame
    batchRender.rects = [];
  }

  public function submit() {
    batchRender.use(context);
    batchRender.draw(context);
  }

  public function resize(width:Int, height:Int) {
    throw new FeintException('NotImplemented', "RenderContext.resize() not implemented for WebGL");
    // TODO: https://webglfundamentals.org/webgl/lessons/webgl-resizing-the-canvas.html
  }

  public function drawRect(
    x:Int,
    y:Int,
    width:Int,
    height:Int,
    ?options:RendererPrimitiveOptions
  ) {
    var color = options != null && options.color != null ? options.color : 0xFFFFFFFF;
    batchRender.addRect(x, y, width, height, color);
  }

  public function drawImage(
    x:Int,
    y:Int,
    assetId:String,
    ?clip:TextureClip,
    ?scale:Float = 1,
    ?textureWidth:Int,
    ?textureHeight:Int
  ) {
    var textureInitialized = textures.exists(assetId);
    var textureLoaded = textureInitialized && textures.get(assetId) != null;
    if (!textureInitialized) {
      var imageElem:ImageElement = cast js.Browser.document.getElementById(assetId);
      var image = new Image();
      if (imageElem.src.indexOf('file://') == 0) {
        throw new FeintException(
          'INVALID_FILESYSTEM_ACCESS',
          'Unable to load assets directly from the filesystem in WebGL, you\'ll need to run this application from a dev server or hosted site'
        );
      }
      requestCORSIfNotSameOrigin(image, imageElem.src);
      image.src = imageElem.src;

      // Set texture to null and add to list
      textures[assetId] = null;
      textureIndex.push(assetId);
      // var index = batchRender.prepTexture(context);
      textureId[assetId] = 0;
      image.addEventListener('load', () -> {
        // Set texture to image after it loads
        textures[assetId] = image;
        textureId[assetId] = batchRender.bindTexture(context, textures[assetId]);
      });
    } else if (textureLoaded) {
      // TODO: Bind texture
    }

    batchRender.addRect(
      x,
      y,
      clip.width * scale,
      clip.height * scale,
      0xFFFFFFFF,
      textureId[assetId]
    );
  }

  public function drawText(x:Int, y:Int, text:String, fontSize:Int, font:String, align:TextAlign) {
    // HTML Overlay: https://webglfundamentals.org/webgl/lessons/webgl-text-html.html
    // Canvas Overlay: https://webglfundamentals.org/webgl/lessons/webgl-text-canvas2d.html
    // Copy from Canvas: https://webglfundamentals.org/webgl/lessons/webgl-text-texture.html
    // BitmapFonts: https://webglfundamentals.org/webgl/lessons/webgl-text-glyphs.html
    // https://css-tricks.com/techniques-for-rendering-text-with-webgl/

    if (textRenderContext != null) {
      textRenderContext.drawText(x, y, text, fontSize, font, align);
    }

    // HTML implementation
    // if (js.Browser.document.getElementById('feint-webgl-text-div') != null) {
    //   var tempTextDisplay = js.Browser.document.getElementById('feint-webgl-text-div');
    //   var textDiv = js.Browser.document.createDivElement();
    //   textDiv.textContent = text;
    //   tempTextDisplay.appendChild(textDiv);
    // }
  }

  function setup() {
    // Handle High DPI screens
    // Fixes font scaling issues on high DPI monitors without changing the actual canvas size
    // See: https://developer.mozilla.org/en-US/docs/Games/Techniques/Crisp_pixel_art_look
    canvas.width = Math.floor(width);
    canvas.height = Math.floor(height);
    canvas.style.width = width + 'px';
    canvas.style.height = height + 'px';
    canvas.style.imageRendering = "pixelated";
    // image-rendering: -moz-crisp-edges;
    // image-rendering: -webkit-crisp-edges;
    // image-rendering: pixelated;
    // image-rendering: crisp-edges;

    batchRender = new BatchRenderWebGLShader();
    batchRender.load();
    batchRender.compile(context);
    textures = [];
    textureId = [];
    textureIndex = [];

    // Allows alpha blending for transparency in textures
    context.enable(RenderingContext.BLEND);
    context.blendFunc(RenderingContext.SRC_ALPHA, RenderingContext.ONE_MINUS_SRC_ALPHA);

    setupTextRenderContext();
  }

  /**
   * Used for rendering text onto a transparent canvas with `drawText`
   */
  function setupTextRenderContext() {
    // Canvas implementation
    textCanvas = js.Browser.document.createCanvasElement();
    textCanvas.id = 'feint-webgl-text';
    textCanvas.width = Std.int(width);
    textCanvas.height = Std.int(height);
    textCanvas.style.position = 'absolute';
    textCanvas.style.top = '0';
    textCanvas.style.left = '0';
    textCanvas.style.zIndex = '1';
    textCanvas.style.background = 'transparent';
    js.Browser.document.body.appendChild(textCanvas);
    final textCanvasContext = textCanvas.getContext('2d');
    textRenderContext = new CanvasRenderContext(textCanvas, textCanvasContext, width, height);

    // HTML implementation
    // if (js.Browser.document.getElementById('feint-webgl-text-div') == null) {
    //   var webglText = js.Browser.document.createDivElement();
    //   webglText.id = 'feint-webgl-text-div';
    //   js.Browser.document.body.appendChild(webglText);
    // }
  }

  /**
   * Make CORS anonymous for loaded images.
   *
   * Testing by just opening an html file will not work without this but in a
   * real production version we should probably not do this.
   * @param img
   * @param url
   * @see https://webglfundamentals.org/webgl/lessons/webgl-cors-permission.html
   */
  function requestCORSIfNotSameOrigin(img, url) {
    var notOrigin = (new URL(
      url,
      js.Browser.window.location.href
    )).origin != js.Browser.window.location.origin;
    if (notOrigin) {
      img.crossOrigin = "anonymous";
    }
  }
}
