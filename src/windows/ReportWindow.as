package windows {
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	
	import ui.button.Button;
	import ui.button.ButtonInfo;
	
	import windows.Window;
	
	public class ReportWindow extends Window {
		
		public static const OK_EVENT:String = "OkEvent";
		
		private static const WINDOW_SIZE:Point = new Point(300, 150);
		
		private static const BUTTON_AREA:uint = 35;
		
		protected static const BUTTON_ROUND:uint = 15;		
		protected static const BUTTON_SIZE:Point = new Point(100, 25);
		
		protected var _message:TextField = new TextField();
		protected var _ok:Button;
		
		public function ReportWindow(windowInfo:WindowInfo, message:String) {
			windowInfo.login = "Сообщение...";
			windowInfo.back.width = WINDOW_SIZE.x;
			windowInfo.back.height = WINDOW_SIZE.y;
			
			super(windowInfo);
			addTextField(message);
			addOKButton();			
		}
		
		public function removeButton():void {
			if (contains(_ok)) removeChild(_ok);
		}
		
		public function addButton():void {
			addOKButton();
		}
		
		public function get message():TextField { return _message; }
		
		private function addTextField(message:String):void {
			_message.x = CONTENT_SHIFT.x;
			_message.y = CONTENT_SHIFT.y;
			_message.width = width - CONTENT_SHIFT.x * 2;
			_message.height = height - BUTTON_AREA;
			
			_message.wordWrap = _message.embedFonts = true;
			_message.mouseEnabled = false;
			_message.defaultTextFormat = Constants.LOG_FORMAT;
			
			_message.text = message;
			
			addChild(_message);
		}
		
		private function addOKButton():void {
			var buttonInfo:ButtonInfo = new ButtonInfo();
			buttonInfo.stage = _windowInfo.stage;
			buttonInfo.size = BUTTON_SIZE;
			buttonInfo.round = BUTTON_ROUND;
			buttonInfo.format = Constants.LOG_FORMAT;
			buttonInfo.back = new Back();
			buttonInfo.label = "Ок";
			buttonInfo.overEffect = Constants.FILTER_2;
			buttonInfo.downEffect = Constants.FILTER_3;
			_ok = new Button(buttonInfo);
			
			_ok.x = width * .5 - _ok.width * .5;
			_ok.y = height - _ok.height - CONTENT_SHIFT.x  * 2;
			_ok.filters = Constants.FILTER_4;
			
			_ok.addEventListener(MouseEvent.CLICK, onClickOK);
			addChild(_ok);
		}
		
		private function onClickOK(e:MouseEvent):void {
			dispatchEvent(new Event(OK_EVENT));
			
			_ok.dispose();
			_ok.removeEventListener(MouseEvent.CLICK, onClickOK);
			
			dispose();		
		}
	}
}