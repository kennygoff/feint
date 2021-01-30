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

  public function drawAt(x:Int, y:Int, renderer:Renderer, ?scale:Float) {
    if (animation != null) {
      renderer.drawImage(
        x,
        y,
        assetId,
        textureWidth,
        textureHeight,
        0,
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
