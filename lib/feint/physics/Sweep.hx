package feint.physics;

import feint.utils.Point;

class Sweep {
  public var hit:Hit;
  public var pos:Point;
  public var time:Float;

  public function new() {
    this.hit = null;
    this.pos = new Point();
    this.time = 1;
  }
}
