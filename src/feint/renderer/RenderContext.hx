package feint.renderer;

import feint.renderer.Renderer.TextureClip;
import feint.renderer.Renderer.TextAlign;
import feint.renderer.Renderer.RendererPrimitiveOptions;

#if js
enum RenderAPI {
  Canvas;
  WebGL;
  WebGL2;
}
#end

interface RenderContext {
  public var api(default, null):RenderAPI;
  public var width(default, null):Int;
  public var height(default, null):Int;

  public function clear(color:Int = 0xFF000000):Void;
  public function resize(width:Int, height:Int):Void;
  public function submit():Void;
  public function drawRect(
    x:Int,
    y:Int,
    width:Int,
    height:Int,
    rotation:Float = 0.0,
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
