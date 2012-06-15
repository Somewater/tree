package windows {
	
	import events.ParamEvent;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextFormat;
	
	public class ClosingWindow extends Window {
		
		private static const SHIFT:uint = 5;
		
		public function ClosingWindow(windowInfo:WindowInfo) {
			super(windowInfo);
			
			windowInfo.close.x = windowInfo.back.width - windowInfo.close.width - SHIFT;
			windowInfo.close.y = SHIFT;			
			windowInfo.close.buttonMode = true;			
			windowInfo.close.addEventListener(MouseEvent.CLICK, onClick);
			
			addChild(windowInfo.close);
		}
		
		private function onClick(e:MouseEvent):void {
			dispose();
		}
		
		/** Переопределение */
		
		public override function dispose():void {
			_windowInfo.close.removeEventListener(MouseEvent.CLICK, onClick);
			super.dispose();
		}
	}
}