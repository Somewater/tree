package tree.common {
	import flash.display.DisplayObjectContainer;
	import flash.display.Stage;
	import flash.utils.Dictionary;

	import tree.loader.ITreeLoader;
	import tree.manager.ITicker;

	public class Config {

		private static var singletones:Dictionary = new Dictionary();

		public static var loader:ITreeLoader;

		public static var WIDTH:int;
		public static var HEIGHT:int;

		public static var GUI_WIDTH:int = 240;
		public static var PANEL_HEIGHT:int = 90;

		public static var canvasHolder:DisplayObjectContainer;
		public static var content:DisplayObjectContainer;
		public static var windows:DisplayObjectContainer;
		public static var tooltips:DisplayObjectContainer;

		public static var stage:Stage;
		public static var ticker:ITicker;

		public static function reject(clazz:Class, singletone:Object):void {
			singletones[clazz] = singletone;
		}

		public static function inject(clazz:Class):* {
			return singletones[clazz];
		}
	}
}
