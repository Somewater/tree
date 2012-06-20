package {
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLLoader;
	
	import utils.Utils;
	
	public class DataLoader extends EventDispatcher {
		
		public static const DATA_LOADED:String = "DataLoaded";
		
		private const FILES:uint = 1;
		
		private var _counter:uint;
		private var _tree:XML;
		
		public function DataLoader() {
			
		}
		
		public function init():void {
			Utils.loadXML(Constants.TREE + Constants.XML_EXP, onLoadTree);
		}
		
		private function check():void {
			_counter++;
			if (_counter == FILES) {
				dispatchEvent(new Event(DATA_LOADED));
			}
		}		
		
		private function onLoadTree(loader:URLLoader):void {
			_tree = new XML(loader.data);
			Initializer.instance.log.append("tree.xml file is loaded successfully!");
			check();
		}
		
		
		public function get tree():XML {
			return _tree;
		}
	}
}