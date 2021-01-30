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
  public var camera:Camera;

  public function clear(color:Int = 0xFF000000):Void;
  public function resize(width:Int, height:Int):Void;
  public function submit():Void;
  public function drawRect(
    x:Int,
    y:Int,
    width:Int,
    height:Int,
    rotation:Float = 0.0,
    color:Int = 0xFFFFFFFF,
    alpha:Float = 1.0,
    depth:Float = 1.0
  ):Void;
  public function drawImage(
    x:Int,
    y:Int,
    assetId:String,
    textureWidth:Int,
    textureHeight:Int,
    rotation:Float = 0,
    scale:Float = 1,
    color:Int = 0xFFFFFFFF,
    alpha:Float = 1.0,
    depth:Float = 1.0,
    ?clip:TextureClip
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
