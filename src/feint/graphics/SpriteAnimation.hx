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
  public var finished(default, null):Bool;

  var frames:Array<SpriteFrame>;
  var animationMap:AnimationMap;
  var currentTick:Int;
  var frameTick:Int;
  var looping:Bool;

  // TODO: Refactor
  final tickTime:Float = 1 / 60 * 1000;
  final tickRoundingError:Float = 1;
  var currentTickTime:Float;

  public function new(frames:Array<SpriteFrame>, animationMap:AnimationMap) {
    this.frames = frames;
    this.animationMap = animationMap;
    this.currentAnimation = null;
    this.looping = false;
    this.finished = false;
    this.currentTickTime = 0;
  }

  /**
   * Play a given animation and specify the animation's framerate
   *
   * @param animationName Name of animation to play
   * @param frameTick Framerate measured in ticks (e.g. frameTick of 15 would be an animation speed of 15/60 aka 4 frames a second)
   */
  public function play(animationName:String, frameTick:Int, ?looping:Bool = false) {
    currentAnimation = animationName;
    currentFrame = 0;
    currentTick = 0;
    currentTickTime = 0;
    this.frameTick = frameTick;
    this.looping = looping;
    this.finished = false;
  }

  public function update(?elapsed:Float = 1 / 60 * 1000) {
    currentTickTime += elapsed;
    if (currentTickTime >= tickTime - tickRoundingError) {
      currentTick++;
      currentTickTime = 0;
    }

    if (currentTick == frameTick) {
      currentTick = 0;

      var ended = currentFrame == animationMap[currentAnimation].length - 1;

      if (ended && looping) {
        currentFrame = 0;
      } else if (!ended) {
        currentFrame++;
      } else if (ended) {
        finished = true;
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
