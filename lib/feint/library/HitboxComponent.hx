package feint.library;

using Lambda;

import feint.forge.Component;

@shape('hitbox')
class HitboxComponent extends Component {
  public var x:Float;
  public var y:Float;
  public var width:Float;
  public var height:Float;

  public function new(x:Float, y:Float, width:Float, height:Float) {
    this.x = x;
    this.y = y;
    this.width = width;
    this.height = height;
  }
}
