package feint.graphics;

import feint.renderer.Renderer;
import feint.graphics.SpriteAnimation.SpriteFrame;
import feint.graphics.SpriteAnimation.AnimationMap;

class Sprite {
  public var animation(default, null):SpriteAnimation;
  public var textureWidth:Int;
  public var textureHeight:Int;
  public var alpha:Float;

  var assetId:String;

  public function new(assetId:String) {
    this.assetId = assetId;
    this.alpha = 1.0;
  }

  /**
   * Setup animations using traditional sprite sheet with equal sized sprite frames in a grid
   * @param frameWidth Width of a frame in pixels
   * @param frameHeight Height of a frame in pixels
   * @param animationMap Map name of animation (String) to an array of frame indecies (Int) in the animation
   */
  public function setupSpriteSheetAnimation(
    frameWidth:Int,
    frameHeight:Int,
    animationMap:AnimationMap
  ) {
    final cols = Math.floor(textureWidth / frameWidth);
    final rows = Math.floor(textureHeight / frameHeight);
    final frames:Array<SpriteFrame> = [
      for (row in 0...rows)
        for (col in 0...cols)
          {
            x: col * frameWidth,
            y: row * frameWidth,
            width: frameWidth,
            height: frameHeight
          }
    ];
    animation = new SpriteAnimation(frames, animationMap);
  }

  public function drawTileAt(
    x:Float,
    y:Float,
    gridWidth:Int,
    gridHeight:Int,
    tileId:Int,
    renderer:Renderer,
    scale:Float = 1
  ) {
    var tileWidth = Math.floor(textureWidth / gridWidth);
    var tileHeight = Math.floor(textureHeight / gridHeight);

    renderer.drawImage(
      x,
      y,
      assetId,
      textureWidth,
      textureHeight,
      0,
      scale,
      scale,
      0xFFFFFFFF,
      1.0,
      0.5,
      {
        x: Math.floor((tileId % gridWidth) * tileWidth),
        y: Math.floor(Math.floor(tileId / gridHeight) * tileHeight),
        width: tileWidth,
        height: tileHeight
      }
    );
  }

  public function drawAt(x:Float, y:Float, renderer:Renderer, scale:Float = 1) {
    if (animation != null) {
      renderer.drawImage(
        x,
        y,
        assetId,
        textureWidth,
        textureHeight,
        0,
        scale,
        scale,
        0xFFFFFFFF,
        1.0,
        0.5,
        animation.getFrame()
      );
    } else {
      renderer.drawImage(
        x,
        y,
        assetId,
        textureWidth,
        textureHeight,
        0,
        scale,
        scale,
        0xFFFFFFFF,
        1.0,
        0.5,
        {
          x: 0,
          y: 0,
          width: textureWidth,
          height: textureHeight
        }
      );
    }
  }
}
