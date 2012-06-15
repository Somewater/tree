package family.tree {
	
	import flash.display.Stage;
	
	import layers.control.LayerController;
	import family.desktop.Desktop;
	
	public class TreeControllInfo {
		
		public var stage:Stage;
		public var layerController:LayerController;
		public var levels:Desktop;
		public var xml:XML;
		
		public function TreeControllInfo(
			stage:Stage,
			layerController:LayerController,
			levels:Desktop,
			xml:XML
		) {
			this.stage = stage;
			this.layerController = layerController;
			this.levels = levels;
			this.xml = xml;
		}
	}
}