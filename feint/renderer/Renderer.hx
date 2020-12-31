package feint.renderer;

typedef RendererPrimitiveOptions = {
	var ?color:Int;
	var ?stroke:Int;
	var ?strokeWidth:Float;
}

class Renderer {
	var renderContext:RenderContext;

	public function new(renderContext:RenderContext) {
		this.renderContext = renderContext;
	}

	public function clear() {
		renderContext.clear();
	}

	public function drawRect(x:Int, y:Int, width:Int, height:Int, ?options:RendererPrimitiveOptions) {
		renderContext.drawRect(x, y, width, height, options);
	}

	public function drawText(x:Int, y:Int, text:String, fontSize:Int, font:String) {
		renderContext.drawText(x, y, text, fontSize, font);
	}
}
