package tree.common {
	import flash.display.DisplayObjectContainer;
	import flash.display.Stage;
	import flash.utils.Dictionary;

	import tree.loader.ITreeLoader;

	public class Config {

		private static var singletones:Dictionary = new Dictionary();

		public static var loader:ITreeLoader;

		public static var WIDTH:int;
		public static var HEIGHT:int;

		public static var GUI_WIDTH:int = 5;

		public static var content:DisplayObjectContainer;
		public static var windows:DisplayObjectContainer;
		public static var tooltips:DisplayObjectContainer;

		public static var stage:Stage;

		public static function reject(clazz:Class, singletone:Object):void {
			singletones[clazz] = singletone;
		}

		public static function inject(clazz:Class):* {
			return singletones[clazz];
		}
	}
}
