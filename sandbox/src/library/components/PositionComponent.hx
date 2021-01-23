package library.components;

import feint.forge.Component;

@shape('position')
class PositionComponent extends Component {
  public var x:Float;
  public var y:Float;

  public function new(x:Float, y:Float) {
    this.x = x;
    this.y = y;
  }
}
