package feint.input;

import feint.renderer.RenderContext2D;
import feint.input.device.Keyboard;

class InputManager {
  public var keyboard(default, null):Keyboard;

  public function new(renderContext:RenderContext2D) {
    keyboard = new Keyboard(renderContext);
  }

  public function update(elapsed:Float) {
    keyboard.flushQueue();
  }
}
