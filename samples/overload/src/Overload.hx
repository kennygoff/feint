package;

import feint.input.device.Keyboard.KeyCode;
import feint.renderer.Renderer;
import feint.Application;
import feint.debug.Logger;
import scenes.OverloadScene;

class Overload extends Application {
  override function init() {
    game.setInitialScene(new OverloadScene());
  }

  static public function main() {
    new Overload({
      title: 'Overload',
      size: {
        width: 640,
        height: 360
      }
    });
  }
}
