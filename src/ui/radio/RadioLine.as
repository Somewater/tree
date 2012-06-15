package ui.radio {
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	
	import utils.Utils;
	
	public class RadioLine extends Sprite implements IUse,IDisposable {
		
		public static const CHANGE_EVENT:String = "CgangeEvent";
		
		private static const SHIFT:uint = 10;
		
		private var _index:int = -1;
		private var _elements:Array = [];
		
		protected var _radioLineInfo:LineInfo;
		
		public function RadioLine(radioLineInfo:LineInfo) {
			_radioLineInfo = radioLineInfo;
		}
		
		public function get index():int { return _index; }
		public function set index(value:int):void {
			if (_index == value) return;
			_index = value;
			
			var radio:Radio = _elements[_index];
			reset();
			radio.select = true;
			
			dispatchEvent(new Event(CHANGE_EVENT));
		}
		
		public function get elements():Array { return _elements; }
		
		private function reset():void {
			for (var i:uint = 0; i < _elements.length; i++) Radio(_elements[i]).select = false;
		}
		
		protected function onClick(e:Event):void {
			var radio:Radio = Radio(e.target);
			if (radio.select) return;
			index = _elements.indexOf(radio);
		}
		
		protected function createBack():Sprite {
			var s:Sprite = Utils.createCircle(
				_radioLineInfo.back[0],
				_radioLineInfo.back[1],
				_radioLineInfo.back[2],
				_radioLineInfo.back[3]
			);
			s.filters = _radioLineInfo.radioFilter;
			return s;
		}
		
		protected function createActive():Sprite {
			var s:Sprite = Utils.createCircle(
				_radioLineInfo.active[0],
				_radioLineInfo.active[1],
				_radioLineInfo.active[2],
				_radioLineInfo.active[3]
			);
			s.filters = _radioLineInfo.radioFilter;
			return s;
		}
		
		/** Интерфейс */
		
		public function init():void {
			var r:Radio;
			var preR:Radio;
			var l:String;
			var login:TextField;
			var back:Sprite;
			var active:Sprite;
			
			for (var i:uint = 0; i < _radioLineInfo.elements.length; i++) {
				l = _radioLineInfo.elements[i];
				if (l) {
					login = Utils.createTextField(_radioLineInfo.loginTextFormat);
					login.text = l;
				}
				
				back = createBack();
				active = createActive();
				
				r = new Radio(back, active, login);
				r.addEventListener(Radio.ON_CLICK_EVENT, onClick);
				r.init();
				r.filters = _radioLineInfo.filters;
				_elements.push(r);
				
				if (i) {
					preR = Radio(_elements[i - 1]);
					if (_radioLineInfo.positionType) { // По вертикали...
						r.y = preR.y + preR.height + _radioLineInfo.shift;
					} else { // По горизонтали...
						r.x = preR.x + preR.width + _radioLineInfo.shift;
					}				
				}
				
				addChild(r);
			}
		}
		
		public function update():void {
			
		}
		
		public function dispose():void {
			
		}
	}
}