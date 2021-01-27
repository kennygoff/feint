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
    ?clip:TextureClip,
    ?scale:Float,
    ?textureWidth:Int,
    ?textureHeight:Int
  ) {
    renderContext.drawImage(x, y, assetId, clip, scale, textureWidth, textureHeight);
  }

  public function submit() {
    renderContext.submit();
  }
}
