package feint.renderer;

import js.html.webgl.UniformLocation;
import js.html.webgl.Buffer;
import js.html.webgl.Program;
import js.html.webgl.Shader;
import js.html.webgl.RenderingContext;
import feint.renderer.Renderer.TextAlign;
import feint.renderer.Renderer.RendererPrimitiveOptions;
import feint.renderer.Renderer.TextureClip;
import js.html.CanvasRenderingContext2D;
import js.html.CanvasElement;
import feint.debug.FeintException;
import feint.debug.Logger;

#if js
enum RenderAPI {
  Canvas;
  WebGL;
  WebGL2;
}
#end

#if js
enum abstract WebGLShaderType(Int) to Int {
  var Vertex = RenderingContext.VERTEX_SHADER;
  var Fragment = RenderingContext.FRAGMENT_SHADER;
}
#end

@:deprecated("Use RenderContext2D")
class RenderContext {
  #if js
  var webCanvas:CanvasElement;
  var webglContext:RenderingContext;
  var canvasContext:CanvasRenderingContext2D;
  // TODO: TEMP
  var webGLPositionAttributeLocation:Int;
  var webGLProgram:Program;
  var webGLPositionBuffer:Buffer;
  var webGLResolutionUniformLocation:UniformLocation;
  var webGLColorUniformLocation:UniformLocation;
  #end
  var api:RenderAPI;
  var width:Int;
  var height:Int;

  public function new(width:Int, height:Int, api:RenderAPI = Canvas) {
    this.width = width;
    this.height = height;
    this.api = api;

    createContext();
  }

  public function clear() {
    #if js
    if (canvasContext != null) {
      canvasContext.clearRect(0, 0, webCanvas.width, webCanvas.height);
      drawRect(0, 0, webCanvas.width, webCanvas.height, {color: 0xFF000000});
    } else if (webglContext != null) {
      // TODO: Resizing
      // See: https://webglfundamentals.org/webgl/lessons/webgl-resizing-the-canvas.html
      // Clear
      webglContext.viewport(0, 0, webglContext.canvas.width, webglContext.canvas.height);
      webglContext.clearColor(0, 0, 0, 1);
      webglContext.clear(RenderingContext.COLOR_BUFFER_BIT);

      // Upload shader
      // TODO: Move out of clear()
      webglContext.useProgram(webGLProgram);
      webglContext.enableVertexAttribArray(webGLPositionAttributeLocation);
      webglContext.bindBuffer(RenderingContext.ARRAY_BUFFER, webGLPositionBuffer);
      var size = 2; // 2 components per iteration
      var type = RenderingContext.FLOAT; // the data is 32bit floats
      var normalize = false; // don't normalize the data
      var stride = 0; // 0 = move forward size * sizeof(type) each iteration to get the next position
      var offset = 0; // start at the beginning of the buffer
      webglContext.vertexAttribPointer(
        webGLPositionAttributeLocation,
        size,
        type,
        normalize,
        stride,
        offset
      );
      webglContext.uniform2f(
        webGLResolutionUniformLocation,
        webglContext.canvas.width,
        webglContext.canvas.height
      );
      tempSetRectangle(webglContext, 50, 50, 100, 20);
      webglContext.uniform4f(webGLColorUniformLocation, 0, 1, 1, 1);

      var primitiveType = RenderingContext.TRIANGLES;
      var offset = 0;
      var count = 6;
      webglContext.drawArrays(primitiveType, offset, count);

      // Second rectangle on the same buffer
      tempSetRectangle(webglContext, 200, 200, 50, 50);
      webglContext.uniform4f(webGLColorUniformLocation, 1, 1, 0, 1);
      webglContext.drawArrays(primitiveType, 0, 6);
      tempSetRectangle(webglContext, 300, 300, 50, 50);
      webglContext.uniform4f(webGLColorUniformLocation, 1, 0, 1, 1);
      webglContext.drawArrays(primitiveType, 0, 6);
    } else {
      Logger.error('RenderContext.clear(): Context not created use Canvas or WebGL');
      throw new FeintException(
        'RenderContextNotCreated',
        'Context not created use Canvas or WebGL.'
      );
    }
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
    if (canvasContext != null) {
      final fillColor = options != null ? options.color : null;
      final strokeColor = options != null ? options.stroke : null;
      final strokeWidth = options != null && options.strokeWidth != null ? options.strokeWidth : 1;

      canvasContext.lineWidth = strokeWidth;
      canvasContext.strokeStyle = colorToRGBA(strokeColor);
      canvasContext.fillStyle = colorToRGBA(fillColor);
      canvasContext.fillRect(x, y, width, height);
      canvasContext.strokeRect(x, y, width, height);
    } else if (webglContext != null) {
      Logger.error('RenderContext.clear(): WebGL Context not implmented');
      throw new FeintException('NotImplemented', 'Not implemented.');
    } else {
      Logger.error('RenderContext.drawRect(): Context not created use Canvas or WebGL');
      throw new FeintException(
        'RenderContextNotCreated',
        'Context not created use Canvas or WebGL.'
      );
    }
    #else
    throw new FeintException('NotImplemented', 'Not implemented.');
    #end
  }

  public function drawText(x:Int, y:Int, text:String, fontSize:Int, font:String, align:TextAlign) {
    #if js
    if (canvasContext != null) {
      canvasContext.textAlign = align;
      canvasContext.fillStyle = colorToRGBA(0xFFFFFFFF);
      canvasContext.font = '${fontSize}px ${font}';
      canvasContext.textBaseline = 'top';
      canvasContext.fillText(text, x, y);
    } else if (webglContext != null) {
      Logger.error('RenderContext.drawText(): WebGL Context not implmented');
      throw new FeintException('NotImplemented', 'Not implemented.');
    } else {
      Logger.error('RenderContext.drawRect(): Context not created use Canvas or WebGL');
      throw new FeintException(
        'RenderContextNotCreated',
        'Context not created use Canvas or WebGL.'
      );
    }
    #else
    throw new FeintException('NotImplemented', 'Not implemented.');
    #end
  }

  public function drawImage(x:Int, y:Int, assetId:String, ?clip:TextureClip, ?scale:Float) {
    #if js
    if (clip != null) {
      if (scale != null) {
        if (canvasContext != null) {
          canvasContext.drawImage(
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
        } else if (webglContext != null) {
          Logger.error('RenderContext.drawImage(): WebGL Context not implmented');
          throw new FeintException('NotImplemented', 'Not implemented.');
        } else {
          Logger.error('RenderContext.drawImage(): Context not created use Canvas or WebGL');
          throw new FeintException(
            'RenderContextNotCreated',
            'Context not created use Canvas or WebGL.'
          );
        }
      } else {
        if (canvasContext != null) {
          canvasContext.drawImage(
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
        } else if (webglContext != null) {
          Logger.error('RenderContext.drawImage(): WebGL Context not implmented');
          throw new FeintException('NotImplemented', 'Not implemented.');
        } else {
          Logger.error('RenderContext.drawImage(): Context not created use Canvas or WebGL');
          throw new FeintException(
            'RenderContextNotCreated',
            'Context not created use Canvas or WebGL.'
          );
        }
      }
    } else {
      if (canvasContext != null) {
        canvasContext.drawImage(cast js.Browser.document.getElementById(assetId), x, y);
      } else if (webglContext != null) {
        Logger.error('RenderContext.drawImage(): WebGL Context not implmented');
        throw new FeintException('NotImplemented', 'Not implemented.');
      } else {
        Logger.error('RenderContext.drawImage(): Context not created use Canvas or WebGL');
        throw new FeintException(
          'RenderContextNotCreated',
          'Context not created use Canvas or WebGL.'
        );
      }
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

    // Create Context with WebGL or Canvas
    if (api == WebGL) {
      webglContext = webCanvas.getContext('webgl');
      if (webglContext == null) {
        Logger.info('WebGL not supported, falling back to Canvas.');
        webglContext = null;
        canvasContext = webCanvas.getContext('2d', {alpha: false});
        api = Canvas;
      } else {
        initializeWebGLContext();
      }
    } else {
      canvasContext = webCanvas.getContext('2d', {alpha: false});
    }

    // Handle High DPI screens
    // Fixes font scaling issues on high DPI monitors without changing the actual canvas size
    webCanvas.width = Math.floor(width * js.Browser.window.devicePixelRatio);
    webCanvas.height = Math.floor(height * js.Browser.window.devicePixelRatio);
    webCanvas.style.width = width + 'px';
    webCanvas.style.height = height + 'px';
    if (canvasContext != null) {
      canvasContext.scale(js.Browser.window.devicePixelRatio, js.Browser.window.devicePixelRatio);
    } else if (webglContext != null) {
      Logger.error(
        'RenderContext.createContext(): WebGL Context scaling for High DPI not implmented'
      );
      // TODO: Ensure high DPI screens work here
      // throw new FeintException('NotImplemented', 'Not implemented.');
    } else {
      Logger.error('RenderContext.createContext(): Context not created use Canvas or WebGL');
      throw new FeintException(
        'RenderContextNotCreated',
        'Context not created use Canvas or WebGL.'
      );
    }

    // Disable smoothing
    if (canvasContext != null) {
      canvasContext.imageSmoothingEnabled = false;
    } else if (webglContext != null) {
      Logger.error(
        'RenderContext.createContext(): WebGL Context image smoothing flag not implmented'
      );
      // TODO: Ensure image smoothing works as expected here
      // throw new FeintException('NotImplemented', 'Not implemented.');
    } else {
      Logger.error('RenderContext.createContext(): Context not created use Canvas or WebGL');
      throw new FeintException(
        'RenderContextNotCreated',
        'Context not created use Canvas or WebGL.'
      );
    }

    Logger.info('Created RenderContext using ${api} API');
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

  #if js
  function initializeWebGLContext() {
    var vertexShaderSource = '
      // an attribute will receive data from a buffer
      attribute vec2 a_position;
      uniform vec2 u_resolution;
      
      // all shaders have a main function
      void main() {
        // convert the position from pixels to 0.0 to 1.0
        vec2 zeroToOne = a_position / u_resolution;
     
        // convert from 0->1 to 0->2
        vec2 zeroToTwo = zeroToOne * 2.0;
     
        // convert from 0->2 to -1->+1 (clip space)
        vec2 clipSpace = zeroToTwo - 1.0;
     
        gl_Position = vec4(clipSpace * vec2(1, -1), 0, 1);
      }
    ';

    var fragmentShaderSource = '
      // fragment shaders don\'t have a default precision so we need
      // to pick one. mediump is a good default
      precision mediump float;

      uniform vec4 u_color;

      void main() {
        gl_FragColor = u_color;
      }
    ';

    var vertexShader = compileWebGLShader(
      webglContext,
      WebGLShaderType.Vertex,
      vertexShaderSource
    );
    var fragmentShader = compileWebGLShader(
      webglContext,
      WebGLShaderType.Fragment,
      fragmentShaderSource
    );
    webGLProgram = createWebGLProgram(webglContext, vertexShader, fragmentShader);
    webGLPositionAttributeLocation = webglContext.getAttribLocation(webGLProgram, "a_position");
    webGLResolutionUniformLocation = webglContext.getUniformLocation(webGLProgram, "u_resolution");
    webGLColorUniformLocation = webglContext.getUniformLocation(webGLProgram, "u_color");
    webGLPositionBuffer = webglContext.createBuffer();
    webglContext.bindBuffer(RenderingContext.ARRAY_BUFFER, webGLPositionBuffer);
    // NOT NEEDED SINCE WE BIND PER RECT
    var positions = [
      0, 0,
      0, 0,
      0, 0,
      0, 0,
      0, 0,
      0, 0,
    ];
    webglContext.bufferData(
      RenderingContext.ARRAY_BUFFER,
      new js.lib.Float32Array(positions),
      RenderingContext.STATIC_DRAW
    );
  }

  function compileWebGLShader(
    context:RenderingContext,
    type:WebGLShaderType,
    source:String
  ):Shader {
    var shader = context.createShader(type);
    context.shaderSource(shader, source);
    context.compileShader(shader);

    var success:Bool = cast context.getShaderParameter(shader, RenderingContext.COMPILE_STATUS);
    if (success) {
      return shader;
    }

    Logger.error(context.getShaderInfoLog(shader));
    context.deleteShader(shader);
    return null;
  }

  function createWebGLProgram(
    context:RenderingContext,
    vertexShader:Shader,
    fragmentShader:Shader
  ):Program {
    var program = context.createProgram();
    context.attachShader(program, vertexShader);
    context.attachShader(program, fragmentShader);
    context.linkProgram(program);

    var success:Bool = cast context.getProgramParameter(program, RenderingContext.LINK_STATUS);
    if (success) {
      return program;
    }

    Logger.error(context.getProgramInfoLog(program));
    context.deleteProgram(program);
    return null;
  }

  function tempSetRectangle(
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

    // NOTE: gl.bufferData(gl.ARRAY_BUFFER, ...) will affect
    // whatever buffer is bound to the `ARRAY_BUFFER` bind point
    // but so far we only have one buffer. If we had more than one
    // buffer we'd want to bind that buffer to `ARRAY_BUFFER` first.

    webglContext.bufferData(RenderingContext.ARRAY_BUFFER, new js.lib.Float32Array([
      x1, y1,
      x2, y1,
      x1, y2,
      x1, y2,
      x2, y1,
      x2, y2
    ]), RenderingContext.STATIC_DRAW);
  }
  #end
}
