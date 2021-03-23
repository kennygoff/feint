package feint.physics;

import feint.physics.Hit.Collider;
import feint.utils.Point;

class AABB {
  public var pos:Point;
  public var half:Point;

  public function new(pos:Point, half:Point) {
    this.pos = pos;
    this.half = half;
  }

  public function intersectPoint(point:Point):Null<Hit> {
    var dx = point.x - this.pos.x;
    var px = this.half.x - Math.abs(dx);
    if (px <= 0.00001) {
      return null;
    }
    var dy = point.y - this.pos.y;
    var py = this.half.y - Math.abs(dy);
    if (py <= 0.00001) {
      return null;
    }
    var hit = new Hit(this);
    if (px < py) {
      var sx = feint.utils.Math.sign(dx);
      hit.delta.x = px * sx;
      hit.normal.x = sx;
      hit.pos.x = this.pos.x + (this.half.x * sx);
      hit.pos.y = point.y;
    } else {
      var sy = feint.utils.Math.sign(dy);
      hit.delta.y = py * sy;
      hit.normal.y = sy;
      hit.pos.x = point.x;
      hit.pos.y = this.pos.y + (this.half.y * sy);
    }
    return hit;
  }

  public function intersectSegment(
    pos:Point,
    delta:Point,
    paddingX:Float = 0,
    paddingY:Float = 0
  ):Null<Hit> {
    var scaleX = 1.0 / delta.x;
    var scaleY = 1.0 / delta.y;
    var signX = feint.utils.Math.sign(scaleX);
    var signY = feint.utils.Math.sign(scaleY);
    var nearTimeX = (this.pos.x - signX * (this.half.x + paddingX) - pos.x) * scaleX;
    var nearTimeY = (this.pos.y - signY * (this.half.y + paddingY) - pos.y) * scaleY;
    var farTimeX = (this.pos.x + signX * (this.half.x + paddingX) - pos.x) * scaleX;
    var farTimeY = (this.pos.y + signY * (this.half.y + paddingY) - pos.y) * scaleY;

    if (nearTimeX > farTimeY || nearTimeY > farTimeX) {
      return null;
    }

    var nearTime = nearTimeX > nearTimeY ? nearTimeX : nearTimeY;
    var farTime = farTimeX < farTimeY ? farTimeX : farTimeY;

    if (nearTime >= 1 || farTime <= 0) {
      return null;
    }

    var hit = new Hit(this);
    hit.time = feint.utils.Math.clampFloat(nearTime, 0, 1);
    if (nearTimeX > nearTimeY) {
      hit.normal.x = -signX;
      hit.normal.y = 0;
    } else {
      hit.normal.x = 0;
      hit.normal.y = -signY;
    }
    hit.delta.x = (1.0 - hit.time) * -delta.x;
    hit.delta.y = (1.0 - hit.time) * -delta.y;
    hit.pos.x = pos.x + delta.x * hit.time;
    hit.pos.y = pos.y + delta.y * hit.time;
    return hit;
  }

  public function intersectAABB(box:AABB):Null<Hit> {
    var dx = box.pos.x - this.pos.x;
    var px = (box.half.x + this.half.x) - Math.abs(dx);
    if (px <= 0) {
      return null;
    }

    var dy = box.pos.y - this.pos.y;
    var py = (box.half.y + this.half.y) - Math.abs(dy);
    if (py <= 0) {
      return null;
    }

    trace(px, py);

    var hit = new Hit(this);
    if (px < py) {
      var sx = feint.utils.Math.sign(dx);
      hit.delta.x = px * sx;
      hit.normal.x = sx;
      hit.pos.x = this.pos.x + (this.half.x * sx);
      hit.pos.y = box.pos.y;
    } else {
      var sy = feint.utils.Math.sign(dy);
      hit.delta.y = py * sy;
      hit.normal.y = sy;
      hit.pos.x = box.pos.x;
      hit.pos.y = this.pos.y + (this.half.y * sy);
    }
    return hit;
  }

  public function sweepAABB(box:AABB, delta:Point):Sweep {
    var sweep = new Sweep();

    if (delta.x == 0 && delta.y == 0) {
      sweep.pos.x = box.pos.x;
      sweep.pos.y = box.pos.y;
      sweep.hit = this.intersectAABB(box);
      sweep.time = sweep.hit != null ? (sweep.hit.time = 0) : 1;
      return sweep;
    }
    sweep.hit = this.intersectSegment(box.pos, delta, box.half.x, box.half.y);
    if (sweep.hit != null) {
      sweep.time = feint.utils.Math.clampFloat(sweep.hit.time - feint.utils.Math.EPSILON, 0, 1);
      sweep.pos.x = box.pos.x + delta.x * sweep.time;
      sweep.pos.y = box.pos.y + delta.y * sweep.time;
      var direction = delta.clone();
      direction.normalize();
      sweep.hit.pos.x = feint.utils.Math.clampFloat(
        sweep.hit.pos.x + direction.x * box.half.x,
        this.pos.x - this.half.x,
        this.pos.x + this.half.x
      );
      sweep.hit.pos.y = feint.utils.Math.clampFloat(
        sweep.hit.pos.y + direction.y * box.half.y,
        this.pos.y - this.half.y,
        this.pos.y + this.half.y
      );
    } else {
      sweep.pos.x = box.pos.x + delta.x;
      sweep.pos.y = box.pos.y + delta.y;
      sweep.time = 1;
    }
    return sweep;
  }

  public function sweepInto(staticColliders:Array<Collider>, delta:Point):Sweep {
    var nearest = new Sweep();
    nearest.time = 1;
    nearest.pos.x = this.pos.x + delta.x;
    nearest.pos.y = this.pos.y + delta.y;
    for (i in 0...staticColliders.length) {
      var sweep = staticColliders[i].sweepAABB(this, delta);
      if (sweep.time < nearest.time) {
        nearest = sweep;
      }
    }
    return nearest;
  }
}
