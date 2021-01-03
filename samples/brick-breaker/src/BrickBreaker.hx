package;

import feint.input.device.Keyboard.KeyCode;
import feint.renderer.Renderer;
import feint.Application;
import feint.debug.Logger;
import scenes.MainMenuScene;

class BrickBreaker extends Application {
  override function init() {
    game.setInitialScene(new MainMenuScene());
  }

  static public function main() {
    new BrickBreaker({
      title: 'Brick Breaker',
      size: {
        width: 640,
        height: 360
      }
    });
  }
}
