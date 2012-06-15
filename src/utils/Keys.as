package utils {
	
	import flash.display.Stage;
	import flash.events.KeyboardEvent;
	
	public class Keys {
		
		public static const ESC:uint = 27;		
		public static const BACKSPACE:uint = 8;
		
		public static const S:uint = 65;
		public static const D:uint = 68;
		public static const W:uint = 87;
		public static const A:uint = 83;
		public static const Q:uint = 81;
		public static const E:uint = 69;
		public static const R:uint = 82;
		public static const T:uint = 84;
		public static const V:uint = 86;
		public static const C:uint = 67;
		public static const L:uint = 76;
		
		public static const WEAPON_1:uint = 49;
		public static const WEAPON_2:uint = 50;
		public static const WEAPON_3:uint = 51;
		
		public static const ARROW_LEFT:uint = 37;
		public static const ARROW_RIGHT:uint = 39;
		public static const ARROW_UP:uint = 38;
		public static const ARROW_DOWN:uint = 40;	
		
		public static const ENTER:uint = 13;
		public static const CTRL:uint = 17;
		public static const INSERT:uint = 45;
		
		/** Последовательности нажатых кнопок */
		public static const TEST:Array = [S, D, W];
		
		private static var _keys:Keys;
		
		private var _stage:Stage;
		private var _downListeners:Array = [];
		private var _upListeners:Array = [];
		
		public function Keys(lock:__) {
			_keys = this;
		}
		
		public static function get instance():Keys {
			if (_keys == null) _keys = new Keys(new __());
			return _keys;
		}
		
		public function setOn(stage:Stage):void {
			_stage = stage;
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyboardDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyboardUp);
		}
		
		public function setOff():void {
			_stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyboardDown);
			_stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyboardUp);
		}
		
		public function addDownListener(listener:Function, key:uint):void {
			if (_downListeners[key] == null) _downListeners[key] = [];
			_downListeners[key].push(listener);
		}
		
		public function removeDownListener(listener:Function, key:uint):void {
			_downListeners[key].length = 0;
		}
		
		public function addUpListener(listener:Function, key:uint):void {
			if (_upListeners[key] == null) _upListeners[key] = [];
			_upListeners[key].push(listener);
		}
		
		public function removeUpListener(listener:Function, key:uint):void {
			_upListeners[key] = null;
		}
		
		public function onKeyboardDown(e:KeyboardEvent):void {
			trace("KeyDown: " + e.keyCode);
			if (_downListeners[e.keyCode] != null) {
				for (var i:uint = 0; i < _downListeners[e.keyCode].length; i++) {
					_downListeners[e.keyCode][i]();
				}
			}
		}
		
		public function onKeyboardUp(e:KeyboardEvent):void {
			trace("KeyUp: " + e.keyCode);
			if (_upListeners[e.keyCode] != null) for (var i:uint = 0; i < _upListeners[e.keyCode].length; i++) _upListeners[e.keyCode][i]();
		} 
		
		/** Совпадает ли последовательность нажатых клавиш */
		/** Возвращает 0 - последовательность нарушена, 1 - последовательность не полная, 2 - последовательность совпала, -1 - ошибка */
		/** target.length <= valid.length */
		public function checkPressKeyData(valid:Array, target:Array):int {
			if (target.length > valid.length) throw new Error("Stop! Error in checkPressKeyData!");
			
			var charCodeTarget:Object;
			var charCodeValid:Object;
			for (var i:uint = 0; i < valid.length; i++) {
				charCodeValid = valid[i];
				charCodeTarget = target[i];
				if (charCodeValid != null && charCodeTarget == null) { // Недобор - последовательность не полная
					return 1;
				}
				if (charCodeTarget == charCodeValid) {
					continue;
				} else { // Последовательность нарушена
					return 0;
				}
			}			
			return 2; // Полное совпадение
		}
	}
}

class __ {
	
	public function __() {
		
	}	
}