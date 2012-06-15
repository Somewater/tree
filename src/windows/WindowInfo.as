package windows {
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.geom.Point;
	import flash.text.TextFormat;
	
	public class WindowInfo {
		
		public var stage:Stage;
		public var login:String;
		public var back:DisplayObject;
		public var close:Sprite;
		public var format:TextFormat;
		
		public function WindowInfo(
			stage:Stage,
			logName:String,
			back:DisplayObject,
			close:Sprite,
			format:TextFormat
		) {
			this.stage = stage;
			this.login = logName;
			this.back = back;
			this.close = close;
			this.format = format;
		}
	}
}