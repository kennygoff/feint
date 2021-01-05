package feint.graphics;

typedef AnimationMap = Map<String, Array<Int>>;

typedef SpriteFrame = {
  x:Int,
  y:Int,
  width:Int,
  height:Int
}

class SpriteAnimation {
  public var currentAnimation(default, null):String;
  public var currentFrame(default, null):Int;

  var frames:Array<SpriteFrame>;
  var animationMap:AnimationMap;
  var currentTick:Int;
  var frameTick:Int;

  public function new(frames:Array<SpriteFrame>, animationMap:AnimationMap) {
    this.frames = frames;
    this.animationMap = animationMap;
    this.currentAnimation = null;
  }

  /**
   * Play a given animation and specify the animation's framerate
   *
   * @param animationName Name of animation to play
   * @param frameTick Framerate measured in ticks (e.g. frameTick of 15 would be an animation speed of 15/60 aka 4 frames a second)
   */
  public function play(animationName:String, frameTick:Int) {
    currentAnimation = animationName;
    currentFrame = 0;
    currentTick = 0;
    this.frameTick = frameTick;
  }

  public function update() {
    currentTick++;

    if (currentTick == frameTick) {
      currentTick = 0;
      currentFrame++;

      if (currentFrame == animationMap[currentAnimation].length) {
        currentFrame = 0;
      }
    }
  }

  public function getFrame():SpriteFrame {
    if (currentAnimation == null) {
      return null;
    }

    return frames[animationMap[currentAnimation][currentFrame]];
  }
}
