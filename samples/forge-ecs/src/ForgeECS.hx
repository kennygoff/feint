package;

import feint.input.device.Keyboard.KeyCode;
import feint.renderer.Renderer;
import feint.Application;
import feint.debug.Logger;
import scenes.ForgeMenuScene;

class ForgeECS extends Application {
  override function init() {
    game.setInitialScene(new ForgeMenuScene());
  }

  static public function main() {
    new ForgeECS({
      title: 'Forge ECS',
      size: {
        width: 640,
        height: 360
      }
    });
  }
}
