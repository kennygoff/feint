import feint.input.device.Keyboard.KeyCode;
import feint.renderer.Renderer;
import feint.Application;
import feint.debug.Logger;

class HelloFeint extends Application {
  var rectColor:Int = 0xFFFF00FF;

  override function init() {
    Logger.info('Initializing');
  }

  override function update(elapsed:Float) {
    super.update(elapsed);

    // Check for enter keypress on this frame
    if (window.inputManager.keyboard.keys[KeyCode.Enter] == JustPressed) {
      rectColor = 0xFF000000 | (Math.floor(
        Math.random() * 0xFF
      ) << 16) | (Math.floor(Math.random() * 0xFF) << 8) | Math.floor(Math.random() * 0xFF);
    }
  }

  override function render(renderer:Renderer) {
    super.render(renderer);

    // Render background
    renderer.drawRect(0, 0, window.width, window.height, {color: 0xFF000000});

    // Render rectangle
    renderer.drawRect(
      Math.floor(window.width / 2 - 25),
      Math.floor(window.height / 2 - 25),
      50,
      50,
      {
        color: rectColor
      }
    );

    // Render text
    renderer.drawText(5, 5, 'Hello, Feint!', 24, 'sans-serif');
    renderer.drawText(5, window.height - 20, 'Press ENTER to change colors', 12, 'sans-serif');
  }

  static public function main() {
    new HelloFeint({
      title: 'Hello Feint',
      size: {
        width: 320,
        height: 180
      }
    });
  }
}
