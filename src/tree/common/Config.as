package tree.common {
	import flash.display.DisplayObjectContainer;

	import tree.loader.ITreeLoader;

	public class Config {
		public static var loader:ITreeLoader;

		public static var WIDTH:int;
		public static var HEIGHT:int;

		public static var content:DisplayObjectContainer;
		public static var windows:DisplayObjectContainer;
		public static var tooltips:DisplayObjectContainer;
	}
}
