package ui.radio {
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	import ui.IComponent;
	
	public class Radio extends Sprite implements IComponent,IUse,IDisposable {
		
		public static const ON_CLICK_EVENT:String = "OnClickEvent";
		
		private static const SHIFT:uint = 10;
		
		private var _back:Sprite;
		private var _active:Sprite;
		private var _text:TextField;
		private var _textContaiter:Sprite;
		
		private var _select:Boolean = false;
		
		public function Radio(
			back:Sprite,
			active:Sprite,
			text:TextField = null
		) {
			_back = back;
			_active = active;
			_text = text;
		}
		
		private function onClick(e:MouseEvent):void {
			dispatchEvent(new Event(ON_CLICK_EVENT));
		}	
		
		private function setText():void {
			if (_text) {
				_textContaiter = new Sprite();
				_textContaiter.addChild(_text);
				
				_textContaiter.graphics.beginFill(0, 0);
				_textContaiter.graphics.drawRect(0, 0, _text.width, _text.height);
				_textContaiter.graphics.endFill();
				
				_textContaiter.x = _back.width + SHIFT;
				_textContaiter.y = _back.height * .5 - _textContaiter.height * .5;
				
				addChild(_textContaiter);
			}
		}
		
		/** Интерфейс */
		
		public function get select():Boolean {
			return _select;
		}
		
		public function set select(value:Boolean):void {
			if (_select == value) return;
			_select = value;
			if (_select) addChild(_active);
			else if (contains(_active)) removeChild(_active);
		}
		
		public function init():void {
			_active.x = _back.width * .5 - _active.width * .5;
			_active.y = _back.height * .5 - _active.height * .5;
			addChild(_back);
			
			addEventListener(MouseEvent.CLICK, onClick);
			
			setText();
		}
		
		public function update():void {
			
		}
		
		public function dispose():void {
			removeEventListener(MouseEvent.CLICK, onClick);
		}
	}
}