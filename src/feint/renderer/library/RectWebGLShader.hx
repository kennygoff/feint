package feint.renderer.library;

import feint.debug.Logger;

using Lambda;

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
  var color:AttributeLocation;
  var position:AttributeLocation;
  var buffer:Buffer;

  public function new() {
    this.rects = [];
  }

  override public function load() {
    vertexShaderSource = '
      attribute vec2 a_position;
      attribute vec4 a_color;

      uniform vec2 u_resolution;

      varying vec4 v_color;
      
      void main() {
        v_color = a_color;

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

      varying vec4 v_color;

      void main() {
        gl_FragColor = v_color;
      }
    ';

  }

  override function compile(context:RenderingContext) {
    super.compile(context);

    position = context.getAttribLocation(program, 'a_position');
    color = context.getAttribLocation(program, 'a_color');
    resolution = context.getUniformLocation(program, 'u_resolution');

    buffer = context.createBuffer();
  }

  override public function globals(context:RenderingContext) {}

  override public function draw(context:RenderingContext) {
    // Global uniforms, won't change per instance
    // TODO: Move to use()
    context.uniform2f(resolution, context.canvas.width, context.canvas.height);

    // Vertex Buffer Object
    context.bindBuffer(RenderingContext.ARRAY_BUFFER, buffer);

    // Vertex Positions
    context.vertexAttribPointer(position, 2, RenderingContext.FLOAT, false, 24, 0);
    context.enableVertexAttribArray(position);

    // Vertex Colors
    context.vertexAttribPointer(color, 4, RenderingContext.FLOAT, false, 24, 8);
    context.enableVertexAttribArray(color);

    #if (debug && false)
    // Profiling for adding data to the buffer
    // TERRIBLE PERF: concat() * rect
    // MEH PERF: push() * rect * count
    // OKAY PERF: Float32Array(size), buffer[i] = val
    // TODO: Keep vertices stored in a format we don't have to do much
    // modification to before the draw call
    var time = Date.now().getTime();
    #end

    // Vertex Data
    var bufferData = rectsToBufferData(rects);
    context.bufferData(RenderingContext.ARRAY_BUFFER, bufferData, RenderingContext.STATIC_DRAW);

    #if (debug && false)
    trace('Data Prep Time: ${Date.now().getTime() - time}');
    #end

    // Draw vertices from vertex buffer
    var primitiveType = RenderingContext.TRIANGLES;
    var offset = 0;
    var count = 6 * rects.length;
    if (count > 65000) {
      // TODO: Determine size allowed for machine
      // TODO: Send in multiple batches if larger
      Logger.warn('Nearing WebGL limit of vertices! ${count}/65535');
    }
    context.drawArrays(primitiveType, offset, count);
  }

  function rectsToBufferData(rects:Array<RectProperties>):Float32Array {
    var verticesPerRect = 6;
    var floatsPerVertex = 6;
    var floatsInBuffer = rects.length * verticesPerRect * floatsPerVertex;
    var bufferData = new js.lib.Float32Array(floatsInBuffer);
    var bi = 0;
    for (i in 0...rects.length) {
      var x1 = rects[i].x;
      var x2 = rects[i].x + rects[i].width;
      var y1 = rects[i].y;
      var y2 = rects[i].y + rects[i].height;
      var color = colorToVec4(rects[i].color);

      bufferData[bi++] = x1;
      bufferData[bi++] = y1;
      bufferData[bi++] = color[0];
      bufferData[bi++] = color[1];
      bufferData[bi++] = color[2];
      bufferData[bi++] = color[3];

      bufferData[bi++] = x2;
      bufferData[bi++] = y1;
      bufferData[bi++] = color[0];
      bufferData[bi++] = color[1];
      bufferData[bi++] = color[2];
      bufferData[bi++] = color[3];

      bufferData[bi++] = x1;
      bufferData[bi++] = y2;
      bufferData[bi++] = color[0];
      bufferData[bi++] = color[1];
      bufferData[bi++] = color[2];
      bufferData[bi++] = color[3];

      bufferData[bi++] = x1;
      bufferData[bi++] = y2;
      bufferData[bi++] = color[0];
      bufferData[bi++] = color[1];
      bufferData[bi++] = color[2];
      bufferData[bi++] = color[3];

      bufferData[bi++] = x2;
      bufferData[bi++] = y1;
      bufferData[bi++] = color[0];
      bufferData[bi++] = color[1];
      bufferData[bi++] = color[2];
      bufferData[bi++] = color[3];

      bufferData[bi++] = x2;
      bufferData[bi++] = y2;
      bufferData[bi++] = color[0];
      bufferData[bi++] = color[1];
      bufferData[bi++] = color[2];
      bufferData[bi++] = color[3];
    }
    return bufferData;
  }

  /**
   * Meh performance
   *
   * ```haxe
   * var floatArr:Array<Float> = [];
   * for (rect in rects) {
   *   pushRectToBufferData(floatArr, rect);
   * }
   * var bufferData = new js.lib.Float32Array(floatArr);
   * ```
   */
  function pushRectToBufferData(bufferData:Array<Float>, rect:RectProperties) {
    var x1 = rect.x;
    var x2 = rect.x + rect.width;
    var y1 = rect.y;
    var y2 = rect.y + rect.height;
    var color = colorToVec4(rect.color);
    bufferData.push(x1);
    bufferData.push(y1);
    bufferData.push(color[0]);
    bufferData.push(color[1]);
    bufferData.push(color[2]);
    bufferData.push(color[3]);
    bufferData.push(x2);
    bufferData.push(y1);
    bufferData.push(color[0]);
    bufferData.push(color[1]);
    bufferData.push(color[2]);
    bufferData.push(color[3]);
    bufferData.push(x1);
    bufferData.push(y2);
    bufferData.push(color[0]);
    bufferData.push(color[1]);
    bufferData.push(color[2]);
    bufferData.push(color[3]);
    bufferData.push(x1);
    bufferData.push(y2);
    bufferData.push(color[0]);
    bufferData.push(color[1]);
    bufferData.push(color[2]);
    bufferData.push(color[3]);
    bufferData.push(x2);
    bufferData.push(y1);
    bufferData.push(color[0]);
    bufferData.push(color[1]);
    bufferData.push(color[2]);
    bufferData.push(color[3]);
    bufferData.push(x2);
    bufferData.push(y2);
    bufferData.push(color[0]);
    bufferData.push(color[1]);
    bufferData.push(color[2]);
    bufferData.push(color[3]);
  }

  /**
   * Not used currently, but useful
   */
  function rectToVertices(rect:RectProperties):Array<Float> {
    var x1 = rect.x;
    var x2 = rect.x + rect.width;
    var y1 = rect.y;
    var y2 = rect.y + rect.height;
    var color = colorToVec4(rect.color);
    return [
      x1, y1, color[0], color[1], color[2], color[3],
      x2, y1, color[0], color[1], color[2], color[3],
      x1, y2, color[0], color[1], color[2], color[3],
      x1, y2, color[0], color[1], color[2], color[3],
      x2, y1, color[0], color[1], color[2], color[3],
      x2, y2, color[0], color[1], color[2], color[3],
    ];
  }

  static inline function colorToVec4(color:Int):Float32Array {
    final alpha:Float = ((color >> 24) & 0xFF) / 255;
    final red:Float = ((color >> 16) & 0xFF) / 255;
    final green:Float = ((color >> 8) & 0xFF) / 255;
    final blue:Float = (color & 0xFF) / 255;

    return cast [red, green, blue, alpha];
  }
}
