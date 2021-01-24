package feint.renderer.library;

import js.lib.Float32Array;
import js.html.webgl.UniformLocation;
import js.html.webgl.Buffer;
import js.html.webgl.RenderingContext;
import feint.renderer.backends.WebGLShader;

typedef AttributeLocation = Int;

typedef RectProperties = {
  var x:Float;
  var y:Float;
  var width:Float;
  var height:Float;
  var color:Int;
}

class RectWebGLShader extends WebGLShader {
  public var currentRect:RectProperties;
  public var rects:Array<RectProperties>;

  var resolution:UniformLocation;
  var color:UniformLocation;
  var position:AttributeLocation;
  var positionBuffer:Buffer;

  public function new() {
    this.rects = [];
  }

  override public function load() {
    vertexShaderSource = '
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

    fragmentShaderSource = '
      precision mediump float;

      uniform vec4 u_color;

      void main() {
        gl_FragColor = u_color;
      }
    ';

  }

  override function compile(context:RenderingContext) {
    super.compile(context);

    position = context.getAttribLocation(program, 'a_position');
    resolution = context.getUniformLocation(program, 'u_resolution');
    color = context.getUniformLocation(program, 'u_color');

    positionBuffer = context.createBuffer();
  }

  override public function globals(context:RenderingContext) {}

  override public function draw(context:RenderingContext) {
    super.draw(context);

    // Global uniforms, won't change per instance
    // TODO: Move to use()
    context.uniform2f(resolution, context.canvas.width, context.canvas.height);

    // Attributes
    context.enableVertexAttribArray(position);
    context.bindBuffer(RenderingContext.ARRAY_BUFFER, positionBuffer);
    var size = 2; // 2 components per iteration
    var type = RenderingContext.FLOAT; // the data is 32bit floats
    var normalize = false; // don't normalize the data
    var stride = 0; // 0 = move forward size * sizeof(type) each iteration to get the next position
    var offset = 0; // start at the beginning of the buffer
    context.vertexAttribPointer(position, size, type, normalize, stride, offset);

    var primitiveType = RenderingContext.TRIANGLES;
    var offset = 0;
    var count = 6;
    setRectangle(context, currentRect.x, currentRect.y, currentRect.width, currentRect.height);

    var colorVec4 = colorToVec4(currentRect.color);

    context.uniform4fv(color, colorVec4);
    context.drawArrays(primitiveType, offset, count);
  }

  function setRectangle(context:RenderingContext, x:Float, y:Float, width:Float, height:Float) {
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
    final alpha:Float = ((color >> 24) & 0xFF) / 255;
    final red:Float = ((color >> 16) & 0xFF) / 255;
    final green:Float = ((color >> 8) & 0xFF) / 255;
    final blue:Float = (color & 0xFF) / 255;

    return cast [red, green, blue, alpha];
  }
}
