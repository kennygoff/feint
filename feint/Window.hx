package feint;

import feint.input.InputManager;
import feint.renderer.RenderContext;

class Window {
	public var renderContext(default, null):RenderContext;
	public var inputManager(default, null):InputManager;
	public var title(default, null):String;
	public var width(default, null):Int;
	public var height(default, null):Int;

	public function new(title:String, width:Int, height:Int) {
		this.title = title;
		this.width = width;
		this.height = height;

		renderContext = new RenderContext(width, height);
		// TODO: Come up with a better way to manage render and input than passing around the render context
		inputManager = new InputManager(renderContext);
	}
}
