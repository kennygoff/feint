package feint.input.device;

import feint.debug.Logger;
import feint.macros.EnumTools;
import js.html.KeyboardEvent;
import feint.renderer.RenderContext;

enum abstract KeyCode(Int) from Int {
	var Enter = KeyboardEvent.DOM_VK_RETURN;
	var Left = KeyboardEvent.DOM_VK_LEFT;
	var Up = KeyboardEvent.DOM_VK_UP;
	var Right = KeyboardEvent.DOM_VK_RIGHT;
	var Down = KeyboardEvent.DOM_VK_DOWN;
	var Zero = KeyboardEvent.DOM_VK_0;
	var One = KeyboardEvent.DOM_VK_1;
	var Two = KeyboardEvent.DOM_VK_2;
	var Three = KeyboardEvent.DOM_VK_3;
	var Four = KeyboardEvent.DOM_VK_4;
	var Five = KeyboardEvent.DOM_VK_5;
	var Six = KeyboardEvent.DOM_VK_6;
	var Seven = KeyboardEvent.DOM_VK_7;
	var Eight = KeyboardEvent.DOM_VK_8;
	var Nine = KeyboardEvent.DOM_VK_9;
	var A = KeyboardEvent.DOM_VK_A;
	var B = KeyboardEvent.DOM_VK_B;
	var C = KeyboardEvent.DOM_VK_C;
	var D = KeyboardEvent.DOM_VK_D;
	var E = KeyboardEvent.DOM_VK_E;
	var F = KeyboardEvent.DOM_VK_F;
	var G = KeyboardEvent.DOM_VK_G;
	var H = KeyboardEvent.DOM_VK_H;
	var I = KeyboardEvent.DOM_VK_I;
	var J = KeyboardEvent.DOM_VK_J;
	var K = KeyboardEvent.DOM_VK_K;
	var L = KeyboardEvent.DOM_VK_L;
	var M = KeyboardEvent.DOM_VK_M;
	var N = KeyboardEvent.DOM_VK_N;
	var O = KeyboardEvent.DOM_VK_O;
	var P = KeyboardEvent.DOM_VK_P;
	var Q = KeyboardEvent.DOM_VK_Q;
	var R = KeyboardEvent.DOM_VK_R;
	var S = KeyboardEvent.DOM_VK_S;
	var T = KeyboardEvent.DOM_VK_T;
	var U = KeyboardEvent.DOM_VK_U;
	var V = KeyboardEvent.DOM_VK_V;
	var W = KeyboardEvent.DOM_VK_W;
	var X = KeyboardEvent.DOM_VK_X;
	var Y = KeyboardEvent.DOM_VK_Y;
	var Z = KeyboardEvent.DOM_VK_Z;
}

enum KeyEvent {
	KeyUp(key:KeyCode);
	KeyDown(key:KeyCode);
}

enum KeyState {
	Released;
	JustReleased;
	Pressed;
	JustPressed;
}

class Keyboard {
	public static final supportedKeyCodes:Array<KeyCode> = EnumTools.getValues(KeyCode);

	public var keys(default, null):Map<KeyCode, KeyState>;

	var eventQueue:Array<KeyEvent>;

	public function new(renderContext:RenderContext) {
		// Initialize Keys
		keys = new Map();
		for (keyCode in supportedKeyCodes) {
			keys[keyCode] = Released;
		}

		// Initialize event queue
		eventQueue = [];

		#if js
		@:privateAccess(RenderContext)
		js.Browser.window.addEventListener('keydown', onKeyDown);
		@:privateAccess(RenderContext)
		js.Browser.window.addEventListener('keyup', onKeyUp);
		#end
	}

	public function flushQueue() {
		for (keyCode => keyEvent in keys) {
			keys[keyCode] = switch (keyEvent) {
				case Released: Released;
				case JustReleased: Released;
				case Pressed: Pressed;
				case JustPressed: Pressed;
			}
		}

		var events = eventQueue;
		eventQueue = [];
		for (event in events) {
			switch (event) {
				case KeyUp(keyCode):
					if (keys[keyCode] == Pressed) {
						keys[keyCode] = JustReleased;
					}
				case KeyDown(keyCode):
					if (keys[keyCode] == Released) {
						keys[keyCode] = JustPressed;
					}
			}
		}
	}

	function onKeyDown(event:KeyboardEvent) {
		if (supportedKeyCodes.contains(event.keyCode)) {
			eventQueue.push(KeyEvent.KeyDown(event.keyCode));
		}
	}

	function onKeyUp(event:KeyboardEvent) {
		if (supportedKeyCodes.contains(event.keyCode)) {
			eventQueue.push(KeyEvent.KeyUp(event.keyCode));
		}
	}
}
