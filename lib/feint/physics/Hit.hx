package feint.physics;

import feint.utils.Point;

typedef Collider = AABB;

class Hit {
  public var collider:Collider;
  public var pos:Point;
  public var delta:Point;
  public var normal:Point;
  public var time:Float;

  public function new(collider:Collider) {
    this.collider = collider;
    this.pos = new Point();
    this.delta = new Point();
    this.normal = new Point();
    this.time = 0;
  }
}
