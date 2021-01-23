# Feint

A game engine for crafting 2D games in Haxe

## Forge ECS

### Defining Components

```haxe
class PositionComponent extends Component {
  public function new(x:Int, y:Int) {
    this.x = x;
    this.y = y;
  }

  public var x:Int;
  public var y:Int;
}
```

### Building Systems & Getting Shapes

```haxe
private typedef Shape = {
  id:EntityId,
  position:PositionComponent
}

class RandomPositionSystem extends System {
  override function update(elapsed:Float) {
    var positions:Array<Shape> = cast forge.getShapes([PositionComponent]);

    for(position in positions) {
      position.position.x = Math.random() * 320;
      position.position.y = Math.random() * 320;
    }
  }
}

class PositionRenderSystem extends RenderSystem {
  override function render(renderer:Renderer) {
    var positions:Array<Shape> = cast forge.getShapes([PositionComponent]);

    for(positions in positions) {
      renderer.drawRect(position.position.x, position.position.y, 1, 1);
    }
  }
}
```

### Creating Entities

```haxe
Entity.create();
```

### Registering the Forge

```haxe
class MyScene extends Scene {
  var forge:Forge;

  override function init() {
    forge = new Forge();
    forge.addEntity(
      Entity.create(),
      [ new PositionComponent() ]
    );
    forge.addSystem(
      new RandomPositionSystem()
    );
    forge.addRenderSystem(
      new PositionRenderSystem()
    );
  }
}
```
