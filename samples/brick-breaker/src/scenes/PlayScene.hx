package scenes;

import feint.input.device.Keyboard.KeyCode;
import feint.input.InputManager;

using Lambda;

import feint.scene.Scene;
import feint.renderer.Renderer;

class PlayScene extends Scene {
  final backgroundColor:Int = 0xFF000000;
  var world:World;
  var paddle:BlockEntity;
  var ball:BlockEntity;
  var bricks:Array<BlockEntity>;

  override public function init() {
    super.init();

    // Setup world
    world = new World(0, 0, game.window.width, game.window.height);

    // Setup paddle
    paddle = new BlockEntity();
    paddle.size = new SizeComponent(64, 12);
    paddle.position = new PositionComponent(
      game.window.width / 2 - paddle.size.width / 2,
      game.window.height - 32
    );
    paddle.velocity = new VelocityComponent(0, 0);

    // Setup ball
    ball = new BlockEntity();
    ball.size = new SizeComponent(12, 12);
    ball.position = new PositionComponent(
      game.window.width / 2 - ball.size.width / 2,
      game.window.height / 2 - ball.size.height / 2
    );
    ball.velocity = new VelocityComponent(1, 1);

    // Setup bricks
    final brickRows = 20;
    final brickCols = 6;
    bricks = [for (x in 0...brickRows) for (y in 0...brickCols) new BlockEntity()];
    bricks.mapi((i, brick) -> {
      var x = i % brickRows;
      var y = Math.floor(i / brickRows);
      brick.size = new SizeComponent(Math.floor((game.window.width - 32 - 40) / 20), 12);
      brick.position = new PositionComponent(16 + (brick.size.width + 2) * x, 16 + (16 * y));
      brick.velocity = new VelocityComponent(0, 0);
      return false; // mapi requires returning something
    });

    // Setup input handler
    PaddleControlSystem.inputManager = game.window.inputManager;
  }

  override public function update(elapsed:Float) {
    super.update(elapsed);

    PaddleControlSystem.update(elapsed, world, [paddle]);
    SimpleMomentumSystem.update(elapsed, world, [paddle]);
    PaddleBounceSystem.update(elapsed, world, paddle, ball);
    SimplePhysicsSystem.update(elapsed, world, [ball]);
    BrickBreakSystem.update(elapsed, world, bricks, ball);
  }

  override public function render(renderer:Renderer) {
    // Render background
    renderer.drawRect(0, 0, game.window.width, game.window.height, {color: backgroundColor});

    super.render(renderer);

    RenderSystem.render(renderer, world, [ball, paddle].concat(bricks));

    // Render FPS
    renderer.drawText(4, 4, 'FPS: ${game.fps}', 16, 'sans-serif');
  }
}

class World {
  public var position:PositionComponent;
  public var size:SizeComponent;

  public function new(x:Int, y:Int, width:Int, height:Int) {
    position = new PositionComponent(x, y);
    size = new SizeComponent(width, height);
  }
}

class SimpleMomentumSystem {
  public static function update(elapsed:Float, world:World, entities:Array<Dynamic>) {
    for (entity in entities) {
      var velocity:VelocityComponent = entity.velocity;
      var position:PositionComponent = entity.position;
      var size:SizeComponent = entity.size;

      // Momentum as per velocity
      position.x += velocity.x;
      position.y += velocity.y;

      // Stay inside bounds
      if (position.x < world.position.x) {
        position.x = 0;
      }
      if (position.x + size.width >= world.position.x + world.size.width) {
        position.x = world.position.x + world.size.width - size.width;
      }
    }
  }
}

class SimplePhysicsSystem {
  public static function update(elapsed:Float, world:World, entities:Array<Dynamic>) {
    for (entity in entities) {
      var velocity:VelocityComponent = entity.velocity;
      var position:PositionComponent = entity.position;
      var size:SizeComponent = entity.size;

      // Momentum as per velocity
      position.x += velocity.x;
      position.y += velocity.y;

      // Bounce off walls
      if (position.x < world.position.x) {
        velocity.x = Math.abs(velocity.x);
      } else if (position.x + size.width >= world.position.x + world.size.width) {
        velocity.x = -Math.abs(velocity.x);
      }

      // Bounce off ceiling and floor
      if (position.y < world.position.y) {
        velocity.y = Math.abs(velocity.y);
      } else if (position.y + size.height >= world.position.y + world.size.height) {
        velocity.y = -Math.abs(velocity.y);
      }
    }
  }

  public static function overlaps(a:Dynamic, b:Dynamic):Bool {
    var aPosition:PositionComponent = a.position;
    var aSize:SizeComponent = a.size;
    var bPosition:PositionComponent = b.position;
    var bSize:SizeComponent = b.size;

    return !(
      aPosition.x > bPosition.x + bSize.width ||
      aPosition.x + aSize.width <= bPosition.x ||
      aPosition.y > bPosition.y + bSize.height ||
      aPosition.y + aSize.height <= bPosition.y
    );
  }
}

class PaddleBounceSystem {
  public static function update(elapsed:Float, world:World, paddle:Dynamic, ball:Dynamic) {
    if (SimplePhysicsSystem.overlaps(paddle, ball)) {
      var paddlePosition:PositionComponent = paddle.position;
      var paddleSize:SizeComponent = paddle.size;
      var ballPosition:PositionComponent = ball.position;
      var ballSize:SizeComponent = ball.size;
      var ballVelocity:VelocityComponent = ball.velocity;

      var ballOrigin = ballPosition.x + ballSize.width / 2;
      if (ballOrigin <= paddlePosition.x + paddleSize.width * 0.15) {
        ball.velocity.x += -1.25;
        ball.velocity.y = -ball.velocity.y + 0.1;
      } else if (ballOrigin <= paddlePosition.x + paddleSize.width * 0.40) {
        ball.velocity.x += -0.35;
        ball.velocity.y = -ball.velocity.y + 0.05;
      } else if (ballOrigin <= paddlePosition.x + paddleSize.width * 0.45) {
        ball.velocity.x += -0.10;
        ball.velocity.y = -ball.velocity.y;
      } else if (ballOrigin >= paddlePosition.x + paddleSize.width * 0.55) {
        ball.velocity.x += 0.10;
        ball.velocity.y = -ball.velocity.y;
      } else if (ballOrigin >= paddlePosition.x + paddleSize.width * 0.60) {
        ball.velocity.x += 0.35;
        ball.velocity.y = -ball.velocity.y + 0.05;
      } else if (ballOrigin >= paddlePosition.x + paddleSize.width * 0.85) {
        ball.velocity.x += 1.35;
        ball.velocity.y = -ball.velocity.y + 0.1;
      } else {
        ball.velocity.x = ball.velocity.x / 2;
        ball.velocity.y = -ball.velocity.y - 0.1;
      }

      ball.velocity.x *= 1.05;
      ball.velocity.y *= 1.05;
    }
  }
}

class PaddleControlSystem {
  public static var inputManager:InputManager;

  public static function update(elapsed:Float, world:World, entities:Array<Dynamic>) {
    for (entity in entities) {
      var velocity:VelocityComponent = entity.velocity;

      if (inputManager.keyboard.keys[KeyCode.Left] == JustPressed) {
        velocity.x = -4;
      } else if (inputManager.keyboard.keys[KeyCode.Left] == Pressed) {
        velocity.x = -3;
      } else if (inputManager.keyboard.keys[KeyCode.Right] == JustPressed) {
        velocity.x = 4;
      } else if (inputManager.keyboard.keys[KeyCode.Right] == Pressed) {
        velocity.x = 3;
      } else if (Math.abs(velocity.x) > 0.25) {
        velocity.x = velocity.x * 0.9; // Slow down
      } else {
        velocity.x = 0; // Full stop
      }
    }
  }
}

class BrickBreakSystem {
  public static function update(
    elapsed:Float,
    world:World,
    entities:Array<Dynamic>,
    ball:Dynamic
  ) {
    var ballPosition:PositionComponent = ball.position;
    var ballSize:SizeComponent = ball.size;
    var ballVelocity:VelocityComponent = ball.velocity;

    for (entity in entities) {
      var position:PositionComponent = entity.position;
      var size:SizeComponent = entity.size;

      if (SimplePhysicsSystem.overlaps(ball, entity)) {
        position.x = -1000;
        ballVelocity.x = -ballVelocity.x;
        ballVelocity.y = -ballVelocity.y;
      }
    }
  }
}

class RenderSystem {
  public static function render(renderer:Renderer, world:World, entities:Array<Dynamic>) {
    for (entity in entities) {
      var position:PositionComponent = entity.position;
      var size:SizeComponent = entity.size;

      renderer.drawRect(
        Math.floor(position.x),
        Math.floor(position.y),
        Math.floor(size.width),
        Math.floor(size.height),
        {
          color: 0xFFFFFFFF
        }
      );
    }
  }
}

class BlockEntity {
  static var instances:Int;

  final id:Int;

  public function new() {
    instances++;
    id = instances;
  }

  public var position:PositionComponent;
  public var size:SizeComponent;
  public var velocity:VelocityComponent;
}

class PositionComponent {
  public function new(x:Float, y:Float) {
    this.x = x;
    this.y = y;
  }

  public var x:Float;
  public var y:Float;
}

class SizeComponent {
  public function new(width:Float, height:Float) {
    this.width = width;
    this.height = height;
  }

  public var width:Float;
  public var height:Float;
}

class VelocityComponent {
  public function new(x:Float, y:Float) {
    this.x = x;
    this.y = y;
  }

  public var x:Float;
  public var y:Float;
}
