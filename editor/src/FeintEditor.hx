package;

import feint.Application;
import feint.assets.macros.ApplicationSettings.ApplicationConfig;

class FeintEditor extends Application {
  override public function init() {
    game.setInitialScene(new scenes.SceneEditor());
  }

  static public function main() {
    var config:ApplicationConfig = feint.assets.macros.ApplicationSettings.getApplicationConfig();
    new FeintEditor({
      title: config.title,
      size: {
        width: config.window.width,
        height: config.window.height
      },
      api: WebGL
    });
  }
}
