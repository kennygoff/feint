package scenes;

import js.Browser;
import ui.Panel;
import ui.Dockspace;
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
  var dockspace:Dockspace;
  var scenePanel:Panel;
  var viewportPanel:Panel;
  var projectPanel:Panel;

  override function init() {
    super.init();

    title = new BitmapText('No Scene Loaded');

    project = Json.parse(
      Fs.readFileSync(
        Path.join(js.Node.process.cwd(), '../../..', 'sandbox', 'feint.config.json'),
        'utf-8'
      )
    );

    title = new BitmapText(project.title);

    dockspace = new Dockspace();
    scenePanel = new Panel('Scene', {}, []);
    viewportPanel = new Panel(
      'Viewport',
      {},
      [(props : {}) -> '<canvas id="feint-editor-viewport"></canvas>']
    );
    projectPanel = new Panel('Project', {project: project}, [
      (props : {project:ApplicationConfig})
    -> '<label><span>Title</span> <input type="text" value="${props.project.title}" /></label>',
      (props : {project:ApplicationConfig})
    ->
        '<label><span>Width</span> <input type="number" value="${props.project.window.width}" /></label>',
      (props : {project:ApplicationConfig})
    ->
        '<label><span>Height</span> <input type="number" value="${props.project.window.height}" /></label>'
    ]);
    dockspace.add([scenePanel, viewportPanel, projectPanel]);

    @:privateAccess(feint.Application)
    game.application.setupRenderer({
      title: project.title,
      size: {
        width: project.window.width,
        height: project.window.height
      },
      api: WebGL,
    });
  }

  override function render(renderer:Renderer) {
    super.render(renderer);

    title.draw(renderer, 4, 4, 16);
    renderer.submit();
  }
}
