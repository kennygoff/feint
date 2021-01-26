package feint.renderer.backends;

import js.html.webgl.Shader;
import js.html.webgl.RenderingContext;
import js.html.webgl.Program;
import feint.debug.Logger;
import feint.renderer.backends.WebGLRenderContext.WebGLShaderType;

class WebGLShader {
  var program:Program;
  var vertexShaderSource:String;
  var fragmentShaderSource:String;

  public function load() {}

  public function compile(context:RenderingContext) {
    var vertexShader = compileShader(context, Vertex, vertexShaderSource);
    var fragmentShader = compileShader(context, Fragment, fragmentShaderSource);
    program = createProgram(context, vertexShader, fragmentShader);
  }

  public function use(context:RenderingContext) {
    context.useProgram(program);
    // Global Uniforms
  }

  public function globals(context:RenderingContext) {
    // Global Uniforms
  }

  public function draw(context:RenderingContext) {
    // Per-Draw Uniforms
    // Vertex Attribute Array
    // Bind Buffer
    // Vertex Attribute Pointer
  }

  /**
   * Create and compile a WebGL shader
   * @param context WebGL Context
   * @param type Type of shader, either Vertex or Fragment
   * @param source Shader source code as a string
   * @return Shader
   */
  private static function compileShader(
    context:RenderingContext,
    type:WebGLShaderType,
    source:String
  ):Shader {
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
  private static function createProgram(
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
}
