package feint.renderer;

typedef RendererPrimitiveOptions = {
  var ?color:Int;
  var ?stroke:Int;
  var ?strokeWidth:Float;
}

typedef TextureClip = {
  var x:Int;
  var y:Int;
  var width:Int;
  var height:Int;
}

enum abstract TextAlign(String) to String {
  var Left = 'left';
  var Center = 'center';
  var Right = 'right';
}

/**
 * Cross-platform 2D rendering API.
 */
class Renderer {
  /**
   * Getter/setter to access the `renderContext`'s camera
   */
  public var camera(get, set):Camera;

  /**
   * Render context for this renderer instance.
   *
   * Platforms and render targets each have their own unique render contexts.
   *
   * Currently supported:
   *
   * - WebGL: `WebGLRenderContext` (targets: js [default])
   * - Canvas: `CanvasRenderContext` (targets: js)
   */
  @:dox(show)
  var renderContext:RenderContext;

  public function new(renderContext:RenderContext) {
    this.renderContext = renderContext;
  }

  /**
   * Clear the render context. Must be called at the start of each frame.
   */
  public function clear() {
    renderContext.clear();
  }

  /**
   * Render a solid color rectangle to a quad.
   *
   * @param x X position
   * @param y Y position
   * @param width Width of the quad
   * @param height Height of the quad
   * @param rotation [radians] Rotation around the top-left corner
   * @param options Additional options
   *
   * **Note:** Stroke and stroke width in `RendererPrimitiveOptions` is ignored
   * in WebGL render context.
   */
  public function drawRect(
    x:Int,
    y:Int,
    width:Int,
    height:Int,
    rotation:Float = 0.0,
    ?options:RendererPrimitiveOptions
  ) {
    renderContext.drawRect(x, y, width, height, rotation, options);
  }

  /**
   * Draw text.
   *
   * @param x X position
   * @param y Y position
   * @param text String of text to render
   * @param fontSize [px] Size of the text
   * @param font Font family to render the text in
   * @param align Text alignment, defaults to `TextAlign.Center`
   *
   * **Note:** For WebGL, this draws on an overlaid canvas object using the
   * Canvas render context, not the WebGL render context.
   */
  public function drawText(
    x:Int,
    y:Int,
    text:String,
    fontSize:Int,
    font:String,
    align:TextAlign = Left
  ) {
    renderContext.drawText(x, y, text, fontSize, font, align);
  }

  /**
   * Draw an image onto a quad.
   *
   * @param x X position
   * @param y Y position
   * @param assetId Asset id as specified by `Asset` macro
   * @param textureWidth Width of the texture
   * @param textureHeight Height of the texture
   * @param rotation [radians] Rotation around the top-left corner
   * @param scale Scale the size of the quad the image is drawn to
   * @param clip Texture clip, specifying what part of a larger texture to draw
   *
   * The image will be drawn at the width/height of the full texture, unless a
   * clip is provided, at which point the clip size will be the width/height.
   *
   * **Note:** For WebGL, this queues the draw for batch rendering with
   * `submit()`. For Canvas on the js target, this draws immediately.
   */
  public function drawImage(
    x:Int,
    y:Int,
    assetId:String,
    textureWidth:Int,
    textureHeight:Int,
    rotation:Float = 0,
    scale:Float = 1,
    ?clip:TextureClip
  ) {
    renderContext.drawImage(x, y, assetId, textureWidth, textureHeight, rotation, scale, clip);
  }

  /**
   * Submit draw call. Must happen at the end of each frame, but can be called
   * sooner to flush the render queue and make a draw call.
   *
   * **Note:** For WebGL, this is required to make the draw call as all other
   * calls simply queue the draws for batch rendering. For Canvas on the js
   * target, this does nothing as there is no batching or render queues.
   */
  public function submit() {
    renderContext.submit();
  }

  @:dox(hide)
  public function get_camera():Camera {
    return renderContext.camera;
  }

  @:dox(hide)
  public function set_camera(camera:Camera):Camera {
    renderContext.camera = camera;
    return renderContext.camera;
  }
}
