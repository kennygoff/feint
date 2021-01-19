package feint.renderer.backends;

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

class WebGLRenderContext implements RenderContext2D {
  public var api(default, null):RenderAPI;
  public var width(default, null):Int;
  public var height(default, null):Int;

  var canvas:CanvasElement;
  var context:RenderingContext;

  // TODO: Temp
  var defaultPositionAttributeLocation:Int;
  var defaultProgram:Program;
  var defaultPositionBuffer:Buffer;
  var defaultResolutionUniformLocation:UniformLocation;
  var defaultColorUniformLocation:UniformLocation;

  public function new(canvas:CanvasElement, context:RenderingContext, width:Int, height:Int) {
    this.width = width;
    this.height = height;
    this.api = Canvas;
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

    submit();
  }

  public function resize(width:Int, height:Int) {
    throw new FeintException(
      'NotImplemented',
      "RenderContext2D.resize() not implemented for WebGL"
    );
    // TODO: https://webglfundamentals.org/webgl/lessons/webgl-resizing-the-canvas.html
  }

  function submit() {
    context.useProgram(defaultProgram);
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
    context.uniform2f(
      defaultResolutionUniformLocation,
      context.canvas.width,
      context.canvas.height
    );
  }

  public function drawRect(
    x:Int,
    y:Int,
    width:Int,
    height:Int,
    ?options:RendererPrimitiveOptions
  ) {
    var primitiveType = RenderingContext.TRIANGLES;
    var offset = 0;
    var count = 6;
    setRectangle(context, x, y, width, height);

    var color = (
      options != null &&
      options.color != null
    ) ? colorToVec4(options.color) : cast [1, 1, 0, 1];

    context.uniform4f(defaultColorUniformLocation, color[0], color[1], color[2], color[3]);
    context.drawArrays(primitiveType, offset, count);
  }

  public function drawImage(x:Int, y:Int, assetId:String, ?clip:TextureClip, ?scale:Float) {
    throw new FeintException(
      'NotImplemented',
      "RenderContext2D.drawImage() not implemented for WebGL"
    );
    // https://webglfundamentals.org/webgl/lessons/webgl-image-processing.html
  }

  public function drawText(x:Int, y:Int, text:String, fontSize:Int, font:String, align:TextAlign) {
    throw new FeintException(
      'NotImplemented',
      "RenderContext2D.drawImage() not implemented for WebGL"
    );
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
      uniform vec2 u_resolution;
      
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
      precision mediump float;

      uniform vec4 u_color;

      void main() {
        gl_FragColor = u_color;
      }
    ';

    var vertexShader = compileShader(context, Vertex, vertexShaderSource);
    var fragmentShader = compileShader(context, Fragment, fragmentShaderSource);
    defaultProgram = createProgram(context, vertexShader, fragmentShader);
    defaultPositionAttributeLocation = context.getAttribLocation(defaultProgram, "a_position");
    defaultResolutionUniformLocation = context.getUniformLocation(defaultProgram, "u_resolution");
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
}
