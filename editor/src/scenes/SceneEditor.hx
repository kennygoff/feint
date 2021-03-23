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
  var dockspace:Dockspace;
  var scenePanel:Panel;
  var viewportPanel:Panel;
  var projectPanel:Panel;

  override function init() {
    super.init();

    project = Json.parse(
      Fs.readFileSync(
        Path.join(js.Node.process.cwd(), '../../..', 'sandbox', 'feint.config.json'),
        'utf-8'
      )
    );

    dockspace = new Dockspace();
    scenePanel = new Panel('Scene', {}, []);
    viewportPanel = new Panel(
      'Viewport',
      {},
      [(props : {}) -> '<canvas id="feint-editor-viewport"></canvas>']
    );
    projectPanel = new Panel('Project', {project: project}, [
      (props : {project:ApplicationConfig})
    -> '<label for="project-title">Title</label>
        <input id="project-title" name="project-title" type="text" value="${props.project.title}" />',
      (props : {project:ApplicationConfig})
    -> '<label for="project-width">Width</label>
        <input id="project-width" name="project-width" type="number" min="0" value="${props.project.window.width}" />',
      (props : {project:ApplicationConfig})
    -> '<label for="project-height">Height</label>
        <input id="project-height" name="project-height" type="number" min="0" value="${props.project.window.height}" />',
    ], 'form');
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
}
