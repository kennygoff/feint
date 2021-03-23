package feint.physics;

import feint.forge.Component;

@shape('rigidBody')
class RigidBodyComponent extends Component {
  public var immovable:Bool;
  public var solid:Bool;
  public var collider:AABB;

  public function new(collider:AABB, solid:Bool = true, immovable:Bool = true) {
    this.collider = collider;
    this.solid = solid;
    this.immovable = immovable;
  }
}
