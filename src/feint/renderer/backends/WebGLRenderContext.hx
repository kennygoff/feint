package feint.renderer.backends;

import feint.renderer.library.RectWebGLShader;
import js.html.URL;
import js.html.ImageElement;
import js.html.Image;
import js.lib.Uint8Array;
import js.html.webgl.Texture;
import feint.debug.FeintException;
import js.lib.Float32Array;
import feint.debug.Logger;
import feint.renderer.Renderer.TextureClip;
import feint.renderer.Renderer.TextAlign;
import feint.renderer.Renderer.RendererPrimitiveOptions;
import js.html.webgl.RenderingContext;
import js.html.webgl.UniformLocation;
import js.html.webgl.Buffer;
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

  // Default Shaders
  var rectShader:RectWebGLShader;

  // TODO: Temp
  var defaultPositionAttributeLocation:Int;
  var defaultTextureCoordinateAttributionLocation:Int;
  var useTexture:UniformLocation;
  var defaultTexture:Texture;
  var defaultProgram:Program;
  var defaultTextureCoordinateBuffer:Buffer;
  var defaultPositionBuffer:Buffer;
  var defaultResolutionUniformLocation:UniformLocation;
  var defaultColorUniformLocation:UniformLocation;
  var textureBound:Map<String, ImageElement> = [];
  var textureLoading:Map<String, Bool> = [];
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

    // TODO: Text solitions
    if (js.Browser.document.getElementById('feint-webgl-text') != null) {
      js.Browser.document.getElementById('feint-webgl-text').innerHTML = '';
    }
    if (textRenderContext != null) {
      // Not using clear() because we default to clearing with a black background
      // textRenderContext.clear();
      @:privateAccess(textRenderContext)
      textRenderContext.context.clearRect(0, 0, canvas.width, canvas.height);
    }

    rectShader.rects = [];
    prepFrame();
  }

  public function submit() {
    rectShader.use(context);
    rectShader.draw(context);
    // for (rect in rectShader.rects) {
    //   rectShader.currentRect = rect;
    //   rectShader.draw(context);
    // }
  }

  public function resize(width:Int, height:Int) {
    throw new FeintException('NotImplemented', "RenderContext.resize() not implemented for WebGL");
    // TODO: https://webglfundamentals.org/webgl/lessons/webgl-resizing-the-canvas.html
  }

  function prepFrame() {
    context.useProgram(defaultProgram);
    // context.blendFunc(RenderingContext.SRC_ALPHA, RenderingContext.ONE_MINUS_SRC_ALPHA);
    // context.bindBuffer(RenderingContext.ARRAY_BUFFER, defaultTextureCoordinateBuffer);
    // context.vertexAttribPointer(
    //   defaultTextureCoordinateAttributionLocation,
    //   size,
    //   type,
    //   normalize,
    //   stride,
    //   offset
    // );
    context.uniform2f(
      defaultResolutionUniformLocation,
      context.canvas.width,
      context.canvas.height
    );
    context.uniform1i(useTexture, 1);
  }

  public function drawRect(
    x:Int,
    y:Int,
    width:Int,
    height:Int,
    ?options:RendererPrimitiveOptions
  ) {
    rectShader.rects.push({
      x: x,
      y: y,
      width: width,
      height: height,
      color: options != null && options.color != null ? options.color : 0xFFFFFFFF
    });
    // rectShader.use(context);
    // rectShader.currentRect = {
    //   x: x,
    //   y: y,
    //   width: width,
    //   height: height,
    //   color: options != null && options.color != null ? options.color : 0xFFFFFFFF
    // };
    // rectShader.draw(context);

    // context.enableVertexAttribArray(defaultPositionAttributeLocation);
    // context.uniform1i(useTexture, 0);
    // context.bindBuffer(RenderingContext.ARRAY_BUFFER, defaultPositionBuffer);
    // var size = 2; // 2 components per iteration
    // var type = RenderingContext.FLOAT; // the data is 32bit floats
    // var normalize = false; // don't normalize the data
    // var stride = 0; // 0 = move forward size * sizeof(type) each iteration to get the next position
    // var offset = 0; // start at the beginning of the buffer
    // context.vertexAttribPointer(
    //   defaultPositionAttributeLocation,
    //   size,
    //   type,
    //   normalize,
    //   stride,
    //   offset
    // );

    // var primitiveType = RenderingContext.TRIANGLES;
    // var offset = 0;
    // var count = 6;
    // setRectangle(context, x, y, width, height);

    // var color = (
    //   options != null &&
    //   options.color != null
    // ) ? colorToVec4(options.color) : cast [0, 1, 1, 1];

    // context.uniform4f(defaultColorUniformLocation, color[0], color[1], color[2], color[3]);
    // context.drawArrays(primitiveType, offset, count);
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
    // TODO: Remove prepFrame call when drawImage has it's own shader program
    prepFrame();

    if (textureBound[assetId] == null) {
      if (textureLoading[assetId] == null) {
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
        image.addEventListener('load', () -> {
          textureLoading[assetId] = true;
          textureBound[assetId] = image;
        });
      }
    } else {
      context.bindTexture(RenderingContext.TEXTURE_2D, defaultTexture);
      context.texImage2D(
        RenderingContext.TEXTURE_2D,
        0,
        RenderingContext.RGBA,
        RenderingContext.RGBA,
        RenderingContext.UNSIGNED_BYTE,
        textureBound[assetId]
      );
      // context.generateMipmap(RenderingContext.TEXTURE_2D);
      if (
        textureWidth != null &&
        textureHeight != null &&
        isPowerOf2(textureWidth) &&
        isPowerOf2(textureHeight) &&
        scale == 1
      ) {
        // Yes, it's a power of 2. Generate mips.
        context.generateMipmap(RenderingContext.TEXTURE_2D);
      } else if (clip != null && isPowerOf2(clip.width) && isPowerOf2(clip.height) && scale == 1) {
        context.generateMipmap(RenderingContext.TEXTURE_2D);
      } else {
        // No, it's not a power of 2. Turn off mips and set wrapping to clamp to edge
        context.texParameteri(
          RenderingContext.TEXTURE_2D,
          RenderingContext.TEXTURE_WRAP_S,
          RenderingContext.CLAMP_TO_EDGE
        );
        context.texParameteri(
          RenderingContext.TEXTURE_2D,
          RenderingContext.TEXTURE_WRAP_T,
          RenderingContext.CLAMP_TO_EDGE
        );
        context.texParameteri(
          RenderingContext.TEXTURE_2D,
          RenderingContext.TEXTURE_MIN_FILTER,
          RenderingContext.NEAREST // LINEAR for non-pixel art
        );
        context.texParameterf(
          RenderingContext.TEXTURE_2D,
          RenderingContext.TEXTURE_MAG_FILTER,
          RenderingContext.NEAREST
        );
      }
    }

    var color = cast [0.5, 0.5, 0.5, 1];
    context.uniform4f(defaultColorUniformLocation, color[0], color[1], color[2], color[3]);
    context.uniform1i(useTexture, 1);

    context.enableVertexAttribArray(defaultPositionAttributeLocation);
    context.bindBuffer(RenderingContext.ARRAY_BUFFER, defaultPositionBuffer);
    var size = 2; // 2 components per iteration
    var type = RenderingContext.FLOAT; // the data is 32bit floats
    var normalize = false; // don't normalize the data
    var stride = 0; // 0 = move forward size * sizeof(type) each iteration to get the next position
    var offset = 0; // start at the beginning of the buffer
    context.vertexAttribPointer(
      defaultPositionAttributeLocation,
      size,
      type,
      normalize,
      stride,
      offset
    );
    setRectangle(context, x, y, clip.width * scale, clip.height * scale);

    context.enableVertexAttribArray(defaultTextureCoordinateAttributionLocation);
    context.bindBuffer(RenderingContext.ARRAY_BUFFER, defaultTextureCoordinateBuffer);
    var size = 2; // 2 components per iteration
    var type = RenderingContext.FLOAT; // the data is 32bit floats
    var normalize = false; // don't normalize the data
    var stride = 0; // 0 = move forward size * sizeof(type) each iteration to get the next position
    var offset = 0; // start at the beginning of the buffer
    context.vertexAttribPointer(
      defaultTextureCoordinateAttributionLocation,
      size,
      type,
      normalize,
      stride,
      offset
    );
    if (textureWidth != null && textureHeight != null) {
      // trace(clip);
      setRectangle(
        context,
        clip.x / textureWidth,
        clip.y / textureHeight,
        clip.width / textureWidth,
        clip.height / textureHeight
      );
    } else {
      setRectangle(context, 0, 0, 1, 1);
    }

    var primitiveType = RenderingContext.TRIANGLES;
    var offset = 0;
    var count = 6;
    context.drawArrays(primitiveType, offset, count);
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

    var vertexShaderSource = '
      attribute vec2 a_position;
      attribute vec2 a_texcoord;

      uniform vec2 u_resolution;

      varying vec2 v_texcoord;
      
      void main() {
        // convert the position from pixels to 0.0 to 1.0
        vec2 zeroToOne = a_position / u_resolution;
     
        // convert from 0->1 to 0->2
        vec2 zeroToTwo = zeroToOne * 2.0;
     
        // convert from 0->2 to -1->+1 (clip space)
        vec2 clipSpace = zeroToTwo - 1.0;
     
        gl_Position = vec4(clipSpace * vec2(1, -1), 0, 1);


        //////

        // convert the position from pixels to 0.0 to 1.0
        vec2 zeroToOne2 = a_position / u_resolution;
     
        // convert from 0->1 to 0->2
        vec2 zeroToTwo2 = zeroToOne2 * 2.0;
     
        // convert from 0->2 to -1->+1 (clip space)
        vec2 clipSpace2 = zeroToTwo2 - 1.0;

        // Pass the texcoord to the fragment shader.     
        v_texcoord = a_texcoord;
      }
    ';

    var fragmentShaderSource = '
      precision mediump float;

      varying vec2 v_texcoord;
 
      uniform sampler2D u_texture;
      uniform vec4 u_color;
      uniform int u_useTexture;

      void main() {
        if(u_useTexture == 1) {
          vec4 texColor = texture2D(u_texture, v_texcoord);
          gl_FragColor = vec4(texColor.rgb, texColor.a);
        } else {
          gl_FragColor = u_color;
        }
      }
    ';

    var vertexShader = compileShader(context, Vertex, vertexShaderSource);
    var fragmentShader = compileShader(context, Fragment, fragmentShaderSource);
    defaultProgram = createProgram(context, vertexShader, fragmentShader);
    defaultPositionAttributeLocation = context.getAttribLocation(defaultProgram, "a_position");
    defaultTextureCoordinateAttributionLocation = context.getAttribLocation(
      defaultProgram,
      "a_texcoord"
    );
    defaultResolutionUniformLocation = context.getUniformLocation(defaultProgram, "u_resolution");
    useTexture = context.getUniformLocation(defaultProgram, "u_useTexture");
    defaultColorUniformLocation = context.getUniformLocation(defaultProgram, "u_color");
    defaultPositionBuffer = context.createBuffer();
    context.bindBuffer(RenderingContext.ARRAY_BUFFER, defaultPositionBuffer);
    // NOT NEEDED SINCE WE BIND PER RECT
    // var positions = [
    //   0, 0,
    //   0, 0,
    //   0, 0,
    //   0, 0,
    //   0, 0,
    //   0, 0,
    // ];
    // context.bufferData(
    //   RenderingContext.ARRAY_BUFFER,
    //   new js.lib.Float32Array(positions),
    //   RenderingContext.STATIC_DRAW
    // );
    defaultTextureCoordinateBuffer = context.createBuffer();
    context.bindBuffer(RenderingContext.ARRAY_BUFFER, defaultTextureCoordinateBuffer);
    defaultTexture = context.createTexture();
    context.bindTexture(RenderingContext.TEXTURE_2D, defaultTexture);
    context.texImage2D(
      RenderingContext.TEXTURE_2D,
      0,
      RenderingContext.RGBA,
      1,
      1,
      0,
      RenderingContext.RGBA,
      RenderingContext.UNSIGNED_BYTE,
      new Uint8Array([0, 255, 255, 255])
    );

    rectShader = new RectWebGLShader();
    rectShader.load();
    rectShader.compile(context);

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
   * Create and compile a WebGL shader
   * @param context WebGL Context
   * @param type Type of shader, either Vertex or Fragment
   * @param source Shader source code as a string
   * @return Shader
   */
  function compileShader(context:RenderingContext, type:WebGLShaderType, source:String):Shader {
    var shader = context.createShader(type);
    context.shaderSource(shader, source);
    context.compileShader(shader);

    var success:Bool = cast context.getShaderParameter(shader, RenderingContext.COMPILE_STATUS);
    if (!success) {
      Logger.error('WebGL shader compilation ' + context.getShaderInfoLog(shader));
      context.deleteShader(shader);
      return null;
    }

    return shader;
  }

  /**
   * Create a WebGL program with a vertex and fragment shader
   * @param context WebGL Context
   * @param vertexShader A compiled WebGL vertex shader
   * @param fragmentShader A compiled WebGL vertex shader
   * @return Program
   */
  function createProgram(
    context:RenderingContext,
    vertexShader:Shader,
    fragmentShader:Shader
  ):Program {
    var program = context.createProgram();
    context.attachShader(program, vertexShader);
    context.attachShader(program, fragmentShader);
    context.linkProgram(program);

    var success:Bool = cast context.getProgramParameter(program, RenderingContext.LINK_STATUS);
    if (!success) {
      Logger.error('WebGL program creation ' + context.getProgramInfoLog(program));
      context.deleteProgram(program);
      return null;
    }

    return program;
  }

  function setRectangle(
    webglContext:RenderingContext,
    x:Float,
    y:Float,
    width:Float,
    height:Float
  ) {
    var x1 = x;
    var x2 = x + width;
    var y1 = y;
    var y2 = y + height;
    context.bufferData(RenderingContext.ARRAY_BUFFER, new js.lib.Float32Array([
      x1, y1,
      x2, y1,
      x1, y2,
      x1, y2,
      x2, y1,
      x2, y2
    ]), RenderingContext.STATIC_DRAW);
  }

  static inline function colorToVec4(color:Int):Float32Array {
    final alpha = ((color >> 24) & 0xFF) / 255;
    final red = (color >> 16) & 0xFF;
    final green = (color >> 8) & 0xFF;
    final blue = color & 0xFF;

    return cast [red, green, blue, alpha];
  }

  static inline function isPowerOf2(value:Int) {
    return (value & (value - 1)) == 0;
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
