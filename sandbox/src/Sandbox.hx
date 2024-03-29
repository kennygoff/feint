package;

import feint.assets.macros.ApplicationSettings.ApplicationConfig;
import feint.Application;

class Sandbox extends Application {
  override public function init() {
    game.setInitialScene(new scenes.BitmapFontScene());
  }

  static public function main() {
    var config:ApplicationConfig = feint.assets.macros.ApplicationSettings.getApplicationConfig();
    new Sandbox({
      title: config.title,
      size: {
        width: config.window.width,
        height: config.window.height
      },
      api: WebGL
    });
  }
}
