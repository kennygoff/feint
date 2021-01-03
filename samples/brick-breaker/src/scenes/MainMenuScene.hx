package scenes;

using Lambda;

import feint.input.device.Keyboard.KeyCode;
import feint.renderer.Renderer;
import feint.scene.Scene;

class MainMenuScene extends Scene {
  final backgroundColor:Int = 0xFF000000;
  var selectedIndex:Int = 0;
  var menuOptions:Array<String> = ['Play', 'Exit'];

  override public function update(elapsed:Float) {
    super.update(elapsed);

    if (game.window.inputManager.keyboard.keys[KeyCode.Down] == JustPressed) {
      selectedIndex = (selectedIndex + 1) % menuOptions.length;
    } else if (game.window.inputManager.keyboard.keys[KeyCode.Up] == JustPressed) {
      selectedIndex = (selectedIndex + menuOptions.length - 1) % menuOptions.length;
    } else if (game.window.inputManager.keyboard.keys[KeyCode.Enter] == JustPressed) {
      if (selectedIndex == menuOptions.indexOf('Play')) {
        game.changeScene(new PlayScene());
        return; // TODO: Decide if this is necessary, optional, or a best practice
      }
    }
  }

  override public function render(renderer:Renderer) {
    // Render background
    renderer.drawRect(0, 0, game.window.width, game.window.height, {color: backgroundColor});

    super.render(renderer);

    // Render Title
    renderer.drawText(32, 32, 'Brick Breaker', 64, 'sans-serif');

    // Render Menu
    menuOptions.mapi((i, menuOptionText) -> {
      renderer.drawText(32, 32 + 64 + 16 + ((32 + 16) * i), menuOptionText, 32, 'sans-serif');
      return false; // mapi requires a return
    });
    renderer.drawRect(
      24,
      32 + 64 + 16 + ((32 + 16) * selectedIndex) + 12,
      4,
      4,
      {color: 0xFFFFFFFF}
    );

    // Render FPS
    renderer.drawText(4, 4, 'FPS: ${game.fps}', 16, 'sans-serif');
  }
}
