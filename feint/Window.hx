package feint;

import feint.renderer.RenderContext;

class Window {
	public var renderContext(default, null):RenderContext;
	public var title(default, null):String;
	public var width(default, null):Int;
	public var height(default, null):Int;

	public function new(title:String, width:Int, height:Int) {
		this.title = title;
		this.width = width;
		this.height = height;

		renderContext = new RenderContext(width, height);
	}
}
