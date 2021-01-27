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

class Renderer {
  public var camera(get, set):Camera;

  var renderContext:RenderContext;

  public function new(renderContext:RenderContext) {
    this.renderContext = renderContext;
  }

  public function clear() {
    renderContext.clear();
  }

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

  public function submit() {
    renderContext.submit();
  }

  public function get_camera():Camera {
    return renderContext.camera;
  }

  public function set_camera(camera:Camera):Camera {
    renderContext.camera = camera;
    return renderContext.camera;
  }
}
