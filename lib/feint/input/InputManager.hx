package feint.input;

import feint.renderer.RenderContext;
import feint.input.device.Keyboard;

class InputManager {
  public var keyboard(default, null):Keyboard;

  public function new(renderContext:RenderContext) {
    keyboard = new Keyboard(renderContext);
  }

  public function update(elapsed:Float) {
    keyboard.flushQueue();
  }
}
