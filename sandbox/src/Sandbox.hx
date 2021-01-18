package;

import feint.Application;

class Sandbox extends Application {
  static public function main() {
    new Sandbox({
      title: "Feint Engine",
      size: {
        width: 640,
        height: 360
      }
    });
  }
}
