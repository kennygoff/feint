package scenes;

import feint.graphics.BitmapText;
import feint.renderer.Renderer;
import haxe.Json;
import js.node.Path;
import js.node.Fs;
import feint.assets.macros.ApplicationSettings.ApplicationConfig;
import feint.scene.Scene;

class SceneEditor extends Scene {
  var project:ApplicationConfig;
  var title:BitmapText;

  override function init() {
    super.init();

    project = Json.parse(
      Fs.readFileSync(Path.join(js.Node.process.cwd(), 'sandbox', 'feint.config.json'), 'utf-8')
    );

    title = new BitmapText(project.title);
  }

  override function render(renderer:Renderer) {
    super.render(renderer);

    title = new BitmapText(project.title);
    title.draw(renderer, 0, 0, 16);
    renderer.submit();
  }
}
