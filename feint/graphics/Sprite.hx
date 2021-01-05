package feint.graphics;

import feint.renderer.Renderer;
import feint.graphics.SpriteAnimation.SpriteFrame;
import feint.graphics.SpriteAnimation.AnimationMap;

class Sprite {
  public var animation(default, null):SpriteAnimation;
  public var textureWidth:Int;
  public var textureHeight:Int;

  var assetId:String;

  public function new(assetId:String) {
    this.assetId = assetId;
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
    trace(cols);
    final rows = Math.floor(textureHeight / frameHeight);
    trace(rows);
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
    trace(frames);
    animation = new SpriteAnimation(frames, animationMap);
  }

  public function drawAt(x:Int, y:Int, renderer:Renderer) {
    if (animation != null) {
      renderer.drawImage(x, y, assetId, animation.getFrame());
    } else {
      renderer.drawImage(x, y, assetId, {
        x: 0,
        y: 0,
        width: 96,
        height: 96
      });
    }
  }
}
