package feint.forge;

import feint.forge.Entity.EntityId;

abstract ComponentType(String) from String to String {
  inline public function new(name:String) {
    this = name;
  }

  @:from
  public static inline function fromClass(componentClass:Class<Component>):ComponentType {
    return Type.getClassName(componentClass);
  }
}

class Component {
  public var entity:EntityId;

  public inline function getComponentType():ComponentType {
    return Type.getClassName(Type.getClass(this));
  }
}
