package feint;

import feint.debug.Logger;
import feint.renderer.Renderer;

typedef ApplicationOptions = {
	title:String,
	size:{
		width:Int, height:Int
	}
}

class Application {
	var name:String;
	var window:Window;
	var game:Game;

	function new(options:ApplicationOptions) {
		setup(options);
		init();
		start();
	}

	public function init() {}

	public function update(elapsed:Float) {
		window.inputManager.update(elapsed);
		game.update(elapsed);
	}

	public function render(renderer:Renderer) {
		game.render();
	}

	/**
	 * Initial setup of application window, renderer, and game.
	 *
	 * WARNING: Do not override, used internally by Application only.
	 * @param options ApplicationOptions
	 */
	private function setup(options:ApplicationOptions) {
		window = new Window(options.title, options.size.width, options.size.height);

		var renderer = new Renderer(window.renderContext);
		game = new Game(renderer);
	}

	function start() {
		requestFrame();
	}

	function requestFrame() {
		#if js
		js.Browser.window.requestAnimationFrame(onFrame);
		#else
		Logger.error('This platform is not supported.');
		throw new FeintException('PlatformNotSupported',
			'Error running Application.start()! This platform is not supported. The currently supported platform is js.');
		#end
	}

	function onFrame(elapsed:Float) {
		update(elapsed);
		@:privateAccess(Game)
		render(game.renderer);

		requestFrame();
	}
}
