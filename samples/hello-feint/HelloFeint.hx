import feint.renderer.Renderer;
import feint.Application;
import feint.debug.Logger;

class HelloFeint extends Application {
	override function init() {
		Logger.info('Hello World');
		Logger.error('Not setup!');
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
	}

	override function render(renderer:Renderer) {
		super.render(renderer);

		// Render background
		renderer.drawRect(0, 0, window.width, window.height, {color: 0xFF000000});

		// Render rectangle
		renderer.drawRect(5, 5, 50, 50, {color: 0xFFFF00FF});

		// Render rectangle
		renderer.drawText(60, 5, 'Hello, Feint!', 24, 'sans-serif');
	}

	static public function main() {
		new HelloFeint({
			title: 'Hello Feint',
			size: {
				width: 320,
				height: 180
			}
		});
	}
}
