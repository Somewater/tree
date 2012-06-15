package windows {
	
	import events.ParamEvent;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import utils.Utils;
	
	public class Window extends Sprite implements IDisposable {
		
		public static const CLOSE_WINDOW_EVENT:String = "CloseWindowEvent";
		
		private static const NAME_POS:Point = new Point(10, 10);
		
		protected static const CONTENT_SHIFT:Point = new Point(10, 40);
		
		protected var _name:TextField;
		protected var _windowInfo:WindowInfo;
				
		public function Window(windowInfo:WindowInfo):void {
			
			_windowInfo = windowInfo;
			
			windowInfo.back.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			windowInfo.back.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			
			_name = new TextField();
			_name.selectable = false;
			_name.autoSize = TextFieldAutoSize.LEFT;
			_name.embedFonts = true;
			_name.wordWrap = true;
			_name.defaultTextFormat = windowInfo.format;
			_name.text = windowInfo.login;
			_name.x = NAME_POS.x;
			_name.y = NAME_POS.y;
			_name.mouseEnabled = false;
			
			addChild(windowInfo.back);
			addChild(_name);
			
			addEventListener(Event.ADDED_TO_STAGE, onEddedToStage);
		}	
		
		public function removeListeners():void {
			_windowInfo.back.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			_windowInfo.back.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}
		
		private function onMouseDown(e:MouseEvent):void {
			startDrag();
			parent.addChild(this);
		}
		
		private function onMouseUp(e:MouseEvent):void {
			stopDrag();
		}
		
		private function mouseLeave(e:Event):void {			
			stopDrag();
    	}	
		
		private function onEddedToStage(e:Event):void {
			x = -width * .5;
			y = -height * .5;
		}
		
		/** Интерфейс */
		
		public function dispose():void {
			removeListeners();
			try { 
				parent.removeChild(this);
			} catch (e:Error) {
				
			}
			dispatchEvent(new ParamEvent(CLOSE_WINDOW_EVENT));
			removeEventListener(Event.ADDED_TO_STAGE, onEddedToStage);
		}
	}
}