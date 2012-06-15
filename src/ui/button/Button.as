package ui.button {
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	public class Button extends Sprite implements IDisposable {
		
		private static const ICON_SHIFT:uint = 10;
		
		private var _buttonInfo:ButtonInfo;
		
		private var _back:Sprite;
		private var _container:Sprite = new Sprite();
		private var _mask:Sprite = new Sprite();
		private var _label:TextField;
		private var _icon:Sprite;
		private var _iconMask:Sprite;
		
		public function Button(buttonInfo:ButtonInfo) {
			_buttonInfo = buttonInfo;
			
			_back = _buttonInfo.back;
			
			if (_buttonInfo.size) {				
				_back.width = _buttonInfo.size.x;
				_back.height = _buttonInfo.size.y;
			}
			
			_mask.graphics.beginFill(0, 0);
			_mask.graphics.drawRoundRect(0, 0, _back.width, _back.height, _buttonInfo.round, _buttonInfo.round);
			_mask.graphics.endFill();
			
			_container.addChild(_back);
			_container.mask = _mask;
			
			if (_buttonInfo.label) {
				_label = new TextField();
				_label.embedFonts = true;
				_label.autoSize = TextFieldAutoSize.LEFT;
				_label.defaultTextFormat = _buttonInfo.format;
				_label.text = _buttonInfo.label;
				
				_label.x = _back.width * .5 - _label.width * .5;
				_label.y = _back.height * .5 - _label.height * .5;
				
				_container.addChild(_label);
			}
			
			_icon = _buttonInfo.icon;
			if (_icon) {
				_icon.x = _back.width - _icon.width - ICON_SHIFT;
				_icon.y = _back.height * .5 - _icon.height * .5;
				
				_iconMask = new Sprite();
				_iconMask.graphics.beginFill(0, 0);
				_iconMask.graphics.drawRoundRect(0, 0, _icon.width, _icon.height, _buttonInfo.round, _buttonInfo.round);
				_iconMask.graphics.endFill();
				_iconMask.x = _icon.x;
				_iconMask.y = _icon.y;
				
				_icon.mask = _iconMask;
				
				_container.addChild(_icon);
				_container.addChild(_iconMask);
			}
				
			_container.mouseEnabled = _container.mouseChildren = false;
			
			addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			
			addChild(_container);
			addChild(_mask);
		}
		
		public function get buttonInfo():ButtonInfo { return _buttonInfo; }
		
		private function onMouseOver(e:MouseEvent):void {
			_back.filters = _buttonInfo.overEffect;
		}
		
		private function onMouseOut(e:MouseEvent):void {
			_back.filters = null;
		}
		
		private function onMouseDown(e:MouseEvent):void {
			_back.filters = _buttonInfo.downEffect;
			_buttonInfo.stage.addEventListener(Event.MOUSE_LEAVE, onMouseLeave);
		}
		
		private function onMouseUp(e:MouseEvent):void {
			_back.filters = null;
			
		}
		
		private function onMouseLeave(e:Event):void {
			onMouseUp(null);
		}
		
		/** Интерфейс */
		
		public function dispose():void {
			removeEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			removeEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			removeEventListener(MouseEvent.MOUSE_UP, onMouseOut);
			
			_buttonInfo.stage.removeEventListener(Event.MOUSE_LEAVE, onMouseLeave);
		}
	}
}