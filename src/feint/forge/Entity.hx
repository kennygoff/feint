package feint.forge;

typedef EntityId = Int;

class Entity {
  public static var INVALID:EntityId = 0;
  public static var nextId:EntityId = 1;

  public static function create():EntityId {
    return nextId++;
  }
}

// class Entity {
//   public static final NONE:EntityId = 0;
//   public static var nextId:EntityId = 1;
//   public static function create(componentTypes:Array<Class<Component>>):EntityId {
//     final id = Entity.nextId++;
//     return id;
//   }
// }
