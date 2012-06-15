package layers.control {
	
	import family.desktop.Desktop;
	import family.desktop.DesktopInteractive;
	import family.item.TreeItem;
	import family.tree.Tree;
	import family.tree.TreeName;
	import family.tree.control.TreeController;
	
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.Event;
	
	import layers.BackgroundLayer;
	import layers.LogLayer;
	import layers.MenuLayer;
	import layers.PopupLayer;
	import layers.TipLayer;
	import layers.TreeDragLayer;
	import layers.TreeLayer;
	import layers.VersionLayer;
	import layers.WindowLayer;
	
	import utils.Utils;
	
	import windows.PopUpWindow;
	import windows.Window;
	import windows.log.Log;
	
	public class LayerController {
		
		private static var _layerController:LayerController;
		
		private var _transformController:TransformController;
		
		/** Слои */
		public var menuLayer:MenuLayer = new MenuLayer();
		
		private var _tipLayer:TipLayer = new TipLayer();
		private var _versionLayer:VersionLayer = new VersionLayer();
		private var _logLayer:LogLayer = new LogLayer();
		private var _popupLayer:PopupLayer = new PopupLayer();
		private var _windowLayer:WindowLayer = new WindowLayer();
		private var _treeLayer:TreeLayer =  new TreeLayer();
		private var _backgroundLayer:BackgroundLayer = new BackgroundLayer();
		
		public static function get instance():LayerController {
			if (_layerController == null) _layerController = new LayerController(new __());
			return _layerController;
		}		
		
		public function LayerController(lock:__) {
			_layerController = this;
			
			_backgroundLayer.init();
			_windowLayer.init();
			_treeLayer.init();
			_popupLayer.init();
			_logLayer.init();
			_versionLayer.init();
			_tipLayer.init();
		
			ConsecutiveFamilyTree.instance.addChild(_backgroundLayer);
			ConsecutiveFamilyTree.instance.addChild(_treeLayer);
			ConsecutiveFamilyTree.instance.addChild(_windowLayer);
			ConsecutiveFamilyTree.instance.addChild(menuLayer);
			ConsecutiveFamilyTree.instance.addChild(_popupLayer);
			ConsecutiveFamilyTree.instance.addChild(_logLayer);
			ConsecutiveFamilyTree.instance.addChild(_versionLayer);
			ConsecutiveFamilyTree.instance.addChild(_tipLayer);
		}
		
		public function resize():void {
			_backgroundLayer.update();
			menuLayer.update();
			_versionLayer.update();
			_treeLayer.update();
			_popupLayer.update();
		}
		
		
		
		
		/** Log */
		
		public function logging():void {
			var log:Log = Initializer.instance.log;
			if (_logLayer.contains(log)) _logLayer.removeChild(log);
			else _logLayer.addChild(log);
		}
		
		
		/** Tree */
		
		public function addDesktop():void {
			var wheelInfo:WheelInfo = new WheelInfo(_treeLayer, Desktop.instance.desktopInfo.wheelLimits);
			_transformController = new TransformController(
				ConsecutiveFamilyTree.instance.stage,
				_treeLayer,
				Desktop.instance,
				wheelInfo
			);
			_transformController.start();
			
			_treeLayer.addChild(Desktop.instance);
			_treeLayer.addChild(DesktopInteractive.instance);
		}
		
		public function addToTreeLayer(object:DisplayObjectContainer):void {
			_treeLayer.addChild(object);
		}
		
		public function removeFromTreeLayer(object:DisplayObjectContainer):void {
			if (_treeLayer.contains(object)) _treeLayer.addChild(object);
		}
				
		public function get treeLayer():TreeLayer { return _treeLayer; }
		public function get transformController():TransformController { return _transformController; }
		
		
		/** Menu */
		
		public function initMenu():void {
			menuLayer.init();
			
			Utils.addOnResize(resize);
			ConsecutiveFamilyTree.instance.stage.dispatchEvent(new Event(Event.RESIZE));
		}
		
		
		/** PoPup */
		
		public function addPopUp(popup:PopUpWindow):void {
			_popupLayer.addChild(popup);
		}
		
		public function clearPopUp():void {
			while(_popupLayer.numChildren) _popupLayer.removeChildAt(0);
		}	
		
		
		/** Stage */
		
		public function lockStage():void {
			ConsecutiveFamilyTree.instance.stage.mouseChildren = false;
		}
		
		public function unlockStage():void {
			ConsecutiveFamilyTree.instance.stage.mouseChildren = true;
		}
	}
}

class __ {
	
}