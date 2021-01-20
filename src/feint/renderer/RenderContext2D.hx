package feint.renderer;

import feint.renderer.RenderContext.RenderAPI;
import feint.renderer.Renderer.TextureClip;
import feint.renderer.Renderer.TextAlign;
import feint.renderer.Renderer.RendererPrimitiveOptions;

interface RenderContext2D {
  public var api(default, null):RenderAPI;
  public var width(default, null):Int;
  public var height(default, null):Int;

  public function clear(color:Int = 0xFF000000):Void;
  public function resize(width:Int, height:Int):Void;
  public function drawRect(
    x:Int,
    y:Int,
    width:Int,
    height:Int,
    ?options:RendererPrimitiveOptions
  ):Void;
  public function drawImage(
    x:Int,
    y:Int,
    assetId:String,
    ?clip:TextureClip,
    ?scale:Float,
    ?textureWidth:Int,
    ?textureHeight:Int
  ):Void;
  public function drawText(
    x:Int,
    y:Int,
    text:String,
    fontSize:Int,
    font:String,
    align:TextAlign
  ):Void;
}
