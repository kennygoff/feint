package;

import feint.input.device.Keyboard.KeyCode;
import feint.renderer.Renderer;
import feint.Application;
import feint.debug.Logger;
import scenes.SpritesScene;

class Sprites extends Application {
  override function init() {
    game.setInitialScene(new SpritesScene());
  }

  static public function main() {
    new Sprites({
      title: 'Sprites',
      size: {
        width: 640,
        height: 360
      }
    });
  }
}
