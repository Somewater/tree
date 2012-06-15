package windows.log  {
	
	import events.ParamEvent;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import windows.ClosingWindow;
	import windows.Window;
	import windows.WindowInfo;
	
	public class Log extends ClosingWindow implements ILog {
		
		private static const SIZE:Point = new Point(600, 400);
		private static const TOP_SHIFT:uint = 40;
		private static const SHIFT:uint = 10;
		private static const LOG_COLOR:Number = 0x999999;
		
		private var _log:TextField = new TextField();
		
		public function Log(windowInfo:WindowInfo) {
			super(windowInfo);
		
			_log.width = windowInfo.back.width - SHIFT * 2;
			_log.height = windowInfo.back.height - TOP_SHIFT - SHIFT;
			_log.embedFonts = true;
			_log.border = true;
			_log.borderColor = LOG_COLOR;
			_log.defaultTextFormat = windowInfo.format;
			_log.x = SHIFT;
			_log.y = TOP_SHIFT;
			
			append("Log is ready!\n");
						
			addChild(_log);
		}
		
		public function kill():void {
			super.dispose();
		}
		
		/** Интерфейс */
		
		public function append(string:String):void {
			_log.appendText(string + "\n");
			_log.scrollV = _log.maxScrollV;
		}
		
		public function clearText():void {
			_log.text = "";
		}
		
		/** Переопределение */
		
		public override function dispose():void {
			try { 
				parent.removeChild(this);
			} catch (e:Error) {
				
			}
			dispatchEvent(new ParamEvent(Window.CLOSE_WINDOW_EVENT));
		}
	}
}