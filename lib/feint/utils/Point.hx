package feint.utils;

class Point {
  public var x:Float;
  public var y:Float;

  public function new(x:Float = 0, y:Float = 0) {
    this.x = x;
    this.y = y;
  }

  public function clone():Point {
    return new Point(this.x, this.y);
  }

  public function normalize():Float {
    var length = this.x * this.x + this.y * this.y;
    if (length > 0) {
      length = std.Math.sqrt(length);
      var inverseLength = 1.0 / length;
      this.x *= inverseLength;
      this.y *= inverseLength;
    } else {
      this.x = 1;
      this.y = 0;
    }
    return length;
  }
}
