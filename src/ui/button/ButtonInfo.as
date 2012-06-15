package ui.button {
	
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.geom.Point;
	import flash.text.TextFormat;
	
	public class ButtonInfo {
		
		public var stage:Stage;
		public var size:Point;
		public var round:uint;
		public var format:TextFormat;
		public var back:Sprite;
		public var label:String;
		public var icon:Sprite;
		public var overEffect:Array;
		public var downEffect:Array;
		
		public function ButtonInfo() {
			
		}
	}
}