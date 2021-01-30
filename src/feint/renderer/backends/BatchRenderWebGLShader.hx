package feint.renderer.backends;

import js.html.webgl.extension.ANGLEInstancedArrays;
import feint.utils.Matrix;

using Lambda;

import js.html.ImageElement;
import js.html.webgl.Buffer;
import js.html.webgl.RenderingContext;
import js.html.webgl.Texture;
import js.html.webgl.UniformLocation;
import js.lib.Uint8Array;
import js.lib.Float32Array;
import feint.debug.FeintException;
import feint.debug.Logger;
import feint.renderer.backends.WebGLShader;
import feint.utils.Math;

typedef AttributeLocation = Int;

typedef OldRectProperties = {
  var x:Float;
  var y:Float;
  var width:Float;
  var height:Float;
  var color:Int;
}

typedef RectProperties = {
  var positions:Array<Float>; // Vec2(XY)[x6]: Position of each vertex in the rect
  var color:Array<Float>; // Vec4(ARGB): Flat color repeated for each position
  var textureIndex:Float; // Float: Index of texture, 0 is identity
  var textureCoordinates:Array<Float>; // Vec2(XY)[x6]: Coordinate of texture clip the vertex corresponds to
  var translation:Array<Float>; // Vec2(XY): Translate
  var rotation:Array<Float>; // Vec2(XY): Rotation
  var alpha:Float; // Float: Alpha
  var depth:Float; // Float: Layer aka Z aka Depth; 0-1 0 being closest to the camera
}

class BatchRenderWebGLShader extends WebGLShader {
  public var rects:Array<RectProperties>;
  public var textureObjects:Array<Texture>;
  public var cameraProjection:Array<Float>;

  var color:AttributeLocation;
  var position:AttributeLocation;
  var textureIndex:AttributeLocation;
  var textureCoordinate:AttributeLocation;
  var rotation:AttributeLocation;
  var translation:AttributeLocation;
  var alpha:AttributeLocation;
  var depth:AttributeLocation;
  var resolution:UniformLocation;
  var textures:UniformLocation;
  var projection:UniformLocation;
  var buffer:Buffer;

  public function new() {
    this.rects = [];
    this.textureObjects = [];
  }

  override public function load() {
    vertexShaderSource = '
      attribute vec2 a_position;
      attribute vec4 a_color;
      attribute float a_textureIndex;
      attribute vec2 a_textureCoordinate;
      attribute vec2 a_translation;
      attribute vec2 a_rotation;
      attribute float a_alpha;
      attribute float a_depth;

      uniform vec2 u_resolution;
      uniform mat3 u_projection;

      varying vec4 v_color;
      varying float v_textureIndex;
      varying vec2 v_textureCoordinate;
      varying float v_alpha;
      
      void main() {
        vec2 rotatedPosition = vec2(
          a_position.x * a_rotation.y + a_position.y * a_rotation.x,
          a_position.y * a_rotation.y - a_position.x * a_rotation.x);
        
        vec2 translatedPosition = rotatedPosition + a_translation;

        vec2 position = (u_projection * vec3(translatedPosition, 1)).xy;

        // convert the position from pixels to 0.0 to 1.0
        vec2 zeroToOne = position / u_resolution;
    
        // convert from 0->1 to 0->2
        vec2 zeroToTwo = zeroToOne * 2.0;
    
        // convert from 0->2 to -1->+1 (clip space)
        vec2 clipSpace = zeroToTwo - 1.0;

        gl_Position = vec4(clipSpace * vec2(1, -1), a_depth, 1);
        v_color = a_color;
        v_textureIndex = a_textureIndex;
        v_textureCoordinate = a_textureCoordinate;
        v_alpha = a_alpha;
      }
    ';

    // Sampler2D arrays!
    // https://stackoverflow.com/questions/19592850/how-to-bind-an-array-of-textures-to-a-webgl-shader-uniform
    fragmentShaderSource = '
      #define maxTextures 8

      precision mediump float;

      uniform sampler2D u_textures[maxTextures];

      varying vec4 v_color;
      varying vec2 v_textureCoordinate;
      varying float v_textureIndex;
      varying float v_alpha;

      vec4 getTextureColorAtIndex(sampler2D textures[maxTextures], int index) {
        vec4 color = vec4(1, 1, 1, 1);
        for (int i = 0; i < maxTextures; ++i) {
          if (i == index) {
            color = texture2D(textures[i], v_textureCoordinate);
          }
        }
        return color;
      }

      void main() {
        vec4 texColor = getTextureColorAtIndex(u_textures, int(v_textureIndex));
        gl_FragColor = v_color * texColor * vec4(1, 1, 1, v_alpha);
      }
    ';

  }

  override function compile(context:RenderingContext) {
    super.compile(context);

    position = context.getAttribLocation(program, 'a_position');
    color = context.getAttribLocation(program, 'a_color');
    textureIndex = context.getAttribLocation(program, 'a_textureIndex');
    textureCoordinate = context.getAttribLocation(program, 'a_textureCoordinate');
    translation = context.getAttribLocation(program, 'a_translation');
    rotation = context.getAttribLocation(program, 'a_rotation');
    alpha = context.getAttribLocation(program, 'a_alpha');
    depth = context.getAttribLocation(program, 'a_depth');
    resolution = context.getUniformLocation(program, 'u_resolution');
    textures = context.getUniformLocation(program, 'u_textures');
    projection = context.getUniformLocation(program, 'u_projection');

    buffer = context.createBuffer();

    bindIdentityTexture(context);
  }

  override public function globals(context:RenderingContext) {}

  override public function draw(context:RenderingContext) {
    if (rects.length == 0) {
      // TODO: See if this even makes sense to warn about
      Logger.warn(
        "Attempting to draw without no vertices, you're likely submitting a render call without queuing any quads to the batch."
      );
      return;
    }

    // Global uniforms, won't change per instance
    // TODO: Move to use()

    // TODO: Camera matrix
    var translationMatrix = Matrix.translation(0, 0);
    var rotationMatrix = Matrix.rotation(0);
    var scaleMatrix = Matrix.scaling(1, 1);
    var temp_translation = Matrix.multiply(translationMatrix, rotationMatrix);
    temp_translation = Matrix.multiply(temp_translation, scaleMatrix);

    // context.useProgram(program);
    context.uniform2f(resolution, context.canvas.width, context.canvas.height);
    context.uniform1iv(textures, [0, 1, 2, 3, 4, 5, 6, 7]);
    context.uniformMatrix3fv(projection, false, cast cameraProjection);

    // Vertex Buffer Object
    context.bindBuffer(RenderingContext.ARRAY_BUFFER, buffer);

    // Vertex size
    var stride = (2 + 4 + 1 + 2 + 2 + 2 + 1 + 1) * 4;
    var offset = 0;

    // Vertex Positions
    context.enableVertexAttribArray(position);
    context.vertexAttribPointer(position, 2, RenderingContext.FLOAT, false, stride, offset);
    offset += 2 * 4;

    // Vertex Colors
    context.enableVertexAttribArray(color);
    context.vertexAttribPointer(color, 4, RenderingContext.FLOAT, false, stride, offset);
    offset += 4 * 4;

    // Vertex Texture Index
    context.enableVertexAttribArray(textureIndex);
    context.vertexAttribPointer(textureIndex, 1, RenderingContext.FLOAT, false, stride, offset);
    offset += 1 * 4;

    // Vertex Texture Coordinate
    context.enableVertexAttribArray(textureCoordinate);
    context.vertexAttribPointer(
      textureCoordinate,
      2,
      RenderingContext.FLOAT,
      false,
      stride,
      offset
    );
    offset += 2 * 4;

    // Vertex Translate
    context.enableVertexAttribArray(translation);
    context.vertexAttribPointer(translation, 2, RenderingContext.FLOAT, false, stride, offset);
    offset += 2 * 4;

    // Vertex Rotation
    context.enableVertexAttribArray(rotation);
    context.vertexAttribPointer(rotation, 2, RenderingContext.FLOAT, false, stride, offset);
    offset += 2 * 4;

    // Vertex Alpha
    context.enableVertexAttribArray(alpha);
    context.vertexAttribPointer(alpha, 1, RenderingContext.FLOAT, false, stride, offset);
    offset += 1 * 4;

    // Vertex Depth
    context.enableVertexAttribArray(depth);
    context.vertexAttribPointer(depth, 1, RenderingContext.FLOAT, false, stride, offset);
    offset += 1 * 4;

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
    } else if (count == 0) {
      Logger.error(
        "Attempting to draw without no vertices, you're likely submitting a render call without queuing any quads to the batch."
      );
      return;
    }
    context.drawArrays(primitiveType, offset, count);
  }

  public function addClipRect(
    x:Float,
    y:Float,
    width:Float,
    height:Float,
    clipX1:Float,
    clipX2:Float,
    clipY1:Float,
    clipY2:Float,
    color:Int,
    rotation:Float = 0.0,
    alpha:Float = 1.0,
    depth:Float = 0.0,
    textureId:Int = 0
  ) {
    rects.push({
      positions: [
            0,      0,
        width,      0,
            0, height,
            0, height,
        width,      0,
        width, height
      ],
      color: cast Math.colorToVec4(color),
      textureIndex: textureId,
      textureCoordinates: [
        clipX1, clipY1,
        clipX2, clipY1,
        clipX1, clipY2,
        clipX1, clipY2,
        clipX2, clipY1,
        clipX2, clipY2,
      ],
      translation: [x, y],
      rotation: [
        std.Math.sin(2 * std.Math.PI - rotation),
        std.Math.cos(2 * std.Math.PI - rotation)
      ],
      alpha: alpha,
      depth: depth
    });
  }

  public function addRect(
    x:Float,
    y:Float,
    width:Float,
    height:Float,
    color:Int,
    rotation:Float = 0.0,
    alpha:Float = 1.0,
    depth:Float = 0.0,
    textureId:Int = 0
  ) {
    var x1 = x;
    var x2 = x + width;
    var y1 = y;
    var y2 = y + height;
    rects.push({
      positions: [
            0,      0,
        width,      0,
            0, height,
            0, height,
        width,      0,
        width, height
      ],
      color: cast Math.colorToVec4(color),
      textureIndex: textureId,
      textureCoordinates: [
        0, 0,
        1, 0,
        0, 1,
        0, 1,
        1, 0,
        1, 1,
      ],
      translation: [x, y],
      rotation: [
        std.Math.sin(2 * std.Math.PI - rotation),
        std.Math.cos(2 * std.Math.PI - rotation)
      ],
      alpha: alpha,
      depth: depth
    });
  }

  public function bindIdentityTexture(context:RenderingContext) {
    var texture:Texture = context.createTexture();
    context.activeTexture(RenderingContext.TEXTURE0);
    context.bindTexture(RenderingContext.TEXTURE_2D, texture);
    context.texImage2D(
      RenderingContext.TEXTURE_2D,
      0,
      RenderingContext.RGBA,
      1,
      1,
      0,
      RenderingContext.RGBA,
      RenderingContext.UNSIGNED_BYTE,
      new Uint8Array([255, 255, 255, 255])
    );
    textureObjects.push(texture);

    for (i in 1...8) {
      context.activeTexture(RenderingContext.TEXTURE0 + i);
      context.bindTexture(RenderingContext.TEXTURE_2D, texture);
      context.texImage2D(
        RenderingContext.TEXTURE_2D,
        0,
        RenderingContext.RGBA,
        1,
        1,
        0,
        RenderingContext.RGBA,
        RenderingContext.UNSIGNED_BYTE,
        new Uint8Array([255, 255, 255, 255])
      );
    }
  }

  /**
   * Temp function that ensures the texture data is not empty in case
   * the shader tries to draw without the texture image loaded
   */
  public function prepTexture(context:RenderingContext):Int {
    if (textureObjects.length >= 8) {
      // TODO: Support proper texture limits and batching
      throw new FeintException(
        'WEBGL_TEXTURE_LIMIT_REACHED',
        'Feint WebGL currently only supports a max of 7 textures! Please combine texture assets if possible and submit up to 7.'
      );
    }

    var index = textureObjects.length;
    var texture:Texture = context.createTexture();
    context.activeTexture(RenderingContext.TEXTURE0 + index);
    context.bindTexture(RenderingContext.TEXTURE_2D, texture);
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
    textureObjects.push(texture);

    return index;
  }

  public function bindTexture(context:RenderingContext, image:ImageElement) {
    if (textureObjects.length >= 8) {
      // TODO: Support proper texture limits and batching
      throw new FeintException(
        'WEBGL_TEXTURE_LIMIT_REACHED',
        'Feint WebGL currently only supports a max of 7 textures! Please combine texture assets if possible and submit up to 7.'
      );
    }

    var index = textureObjects.length;
    context.activeTexture(RenderingContext.TEXTURE0 + index);
    var texture = context.createTexture();
    // var texture:Texture = textureObjects[index];
    context.bindTexture(RenderingContext.TEXTURE_2D, texture);
    context.texImage2D(
      RenderingContext.TEXTURE_2D,
      0,
      RenderingContext.RGBA,
      RenderingContext.RGBA,
      RenderingContext.UNSIGNED_BYTE,
      image
    );

    // TODO: Lol what is a mipmap exactly?
    var useMipMap =
      image.width != null &&
      image.height != null &&
      Math.isPowerOf2(image.width) &&
      Math.isPowerOf2(image.height);
    // var useMipMap = scale == 1;
    // var useMipMap = clip != null && isPowerOf2(clip.width) && isPowerOf2(clip.height);
    if (useMipMap) {
      // Yes, it's a power of 2. Generate mips.
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

    textureObjects.push(texture);
    return index;
  }

  function rectsToBufferData(rects:Array<RectProperties>):Float32Array {
    var verticesPerRect = 6;
    var floatsPerVertex = 15;
    var bufferSize = rects.length * verticesPerRect * floatsPerVertex;
    var bufferData = new js.lib.Float32Array(bufferSize);
    var bi = 0; // Buffer index
    for (i in 0...rects.length) {
      bufferData[bi++] = rects[i].positions[0];
      bufferData[bi++] = rects[i].positions[1];
      bufferData[bi++] = rects[i].color[0];
      bufferData[bi++] = rects[i].color[1];
      bufferData[bi++] = rects[i].color[2];
      bufferData[bi++] = rects[i].color[3];
      bufferData[bi++] = rects[i].textureIndex;
      bufferData[bi++] = rects[i].textureCoordinates[0];
      bufferData[bi++] = rects[i].textureCoordinates[1];
      bufferData[bi++] = rects[i].translation[0];
      bufferData[bi++] = rects[i].translation[1];
      bufferData[bi++] = rects[i].rotation[0];
      bufferData[bi++] = rects[i].rotation[1];
      bufferData[bi++] = rects[i].alpha;
      bufferData[bi++] = rects[i].depth;

      bufferData[bi++] = rects[i].positions[2];
      bufferData[bi++] = rects[i].positions[3];
      bufferData[bi++] = rects[i].color[0];
      bufferData[bi++] = rects[i].color[1];
      bufferData[bi++] = rects[i].color[2];
      bufferData[bi++] = rects[i].color[3];
      bufferData[bi++] = rects[i].textureIndex;
      bufferData[bi++] = rects[i].textureCoordinates[2];
      bufferData[bi++] = rects[i].textureCoordinates[3];
      bufferData[bi++] = rects[i].translation[0];
      bufferData[bi++] = rects[i].translation[1];
      bufferData[bi++] = rects[i].rotation[0];
      bufferData[bi++] = rects[i].rotation[1];
      bufferData[bi++] = rects[i].alpha;
      bufferData[bi++] = rects[i].depth;

      bufferData[bi++] = rects[i].positions[4];
      bufferData[bi++] = rects[i].positions[5];
      bufferData[bi++] = rects[i].color[0];
      bufferData[bi++] = rects[i].color[1];
      bufferData[bi++] = rects[i].color[2];
      bufferData[bi++] = rects[i].color[3];
      bufferData[bi++] = rects[i].textureIndex;
      bufferData[bi++] = rects[i].textureCoordinates[4];
      bufferData[bi++] = rects[i].textureCoordinates[5];
      bufferData[bi++] = rects[i].translation[0];
      bufferData[bi++] = rects[i].translation[1];
      bufferData[bi++] = rects[i].rotation[0];
      bufferData[bi++] = rects[i].rotation[1];
      bufferData[bi++] = rects[i].alpha;
      bufferData[bi++] = rects[i].depth;

      bufferData[bi++] = rects[i].positions[6];
      bufferData[bi++] = rects[i].positions[7];
      bufferData[bi++] = rects[i].color[0];
      bufferData[bi++] = rects[i].color[1];
      bufferData[bi++] = rects[i].color[2];
      bufferData[bi++] = rects[i].color[3];
      bufferData[bi++] = rects[i].textureIndex;
      bufferData[bi++] = rects[i].textureCoordinates[6];
      bufferData[bi++] = rects[i].textureCoordinates[7];
      bufferData[bi++] = rects[i].translation[0];
      bufferData[bi++] = rects[i].translation[1];
      bufferData[bi++] = rects[i].rotation[0];
      bufferData[bi++] = rects[i].rotation[1];
      bufferData[bi++] = rects[i].alpha;
      bufferData[bi++] = rects[i].depth;

      bufferData[bi++] = rects[i].positions[8];
      bufferData[bi++] = rects[i].positions[9];
      bufferData[bi++] = rects[i].color[0];
      bufferData[bi++] = rects[i].color[1];
      bufferData[bi++] = rects[i].color[2];
      bufferData[bi++] = rects[i].color[3];
      bufferData[bi++] = rects[i].textureIndex;
      bufferData[bi++] = rects[i].textureCoordinates[8];
      bufferData[bi++] = rects[i].textureCoordinates[9];
      bufferData[bi++] = rects[i].translation[0];
      bufferData[bi++] = rects[i].translation[1];
      bufferData[bi++] = rects[i].rotation[0];
      bufferData[bi++] = rects[i].rotation[1];
      bufferData[bi++] = rects[i].alpha;
      bufferData[bi++] = rects[i].depth;

      bufferData[bi++] = rects[i].positions[10];
      bufferData[bi++] = rects[i].positions[11];
      bufferData[bi++] = rects[i].color[0];
      bufferData[bi++] = rects[i].color[1];
      bufferData[bi++] = rects[i].color[2];
      bufferData[bi++] = rects[i].color[3];
      bufferData[bi++] = rects[i].textureIndex;
      bufferData[bi++] = rects[i].textureCoordinates[10];
      bufferData[bi++] = rects[i].textureCoordinates[11];
      bufferData[bi++] = rects[i].translation[0];
      bufferData[bi++] = rects[i].translation[1];
      bufferData[bi++] = rects[i].rotation[0];
      bufferData[bi++] = rects[i].rotation[1];
      bufferData[bi++] = rects[i].alpha;
      bufferData[bi++] = rects[i].depth;
    }
    return bufferData;
  }

  /**
   * Not used currently, but useful
   */
  function rectToVertices(rect:OldRectProperties):Array<Float> {
    var x1 = rect.x;
    var x2 = rect.x + rect.width;
    var y1 = rect.y;
    var y2 = rect.y + rect.height;
    var color = Math.colorToVec4(rect.color);
    return [
      x1, y1, color[0], color[1], color[2], color[3],
      x2, y1, color[0], color[1], color[2], color[3],
      x1, y2, color[0], color[1], color[2], color[3],
      x1, y2, color[0], color[1], color[2], color[3],
      x2, y1, color[0], color[1], color[2], color[3],
      x2, y2, color[0], color[1], color[2], color[3],
    ];
  }
}
