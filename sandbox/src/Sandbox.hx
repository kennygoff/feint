package;

import feint.Application;

class Sandbox extends Application {
  override public function init() {
    game.setInitialScene(new scenes.SandboxScene());
  }

  static public function main() {
    new Sandbox({
      title: "Feint Engine",
      size: {
        width: 640,
        height: 360
      },
    });
  }
}
