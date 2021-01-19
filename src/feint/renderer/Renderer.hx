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
  var renderContext:RenderContext2D;

  public function new(renderContext:RenderContext2D) {
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
    ?options:RendererPrimitiveOptions
  ) {
    renderContext.drawRect(x, y, width, height, options);
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

  public function drawImage(x:Int, y:Int, assetId:String, ?clip:TextureClip, ?scale:Float) {
    renderContext.drawImage(x, y, assetId, clip, scale);
  }
}
