package {
	
	import caurina.transitions.properties.ColorShortcuts;
	import caurina.transitions.properties.FilterShortcuts;
	
	import family.desktop.Desktop;
	import family.desktop.DesktopInfo;
	import family.level.LevelCellInfo;
	import family.tree.Tree;
	import family.tree.TreeControllInfo;
	import family.tree.control.TreeController;
	
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	
	import layers.control.LayerController;
	
	import utils.Keys;
	import utils.Utils;
	
	import windows.WindowInfo;
	import windows.log.Log;
	
	public class Initializer {
		
		private static const LOG_SIZE:Point = new Point(500, 500);
		
		private static var _initializer:Initializer;
		
		public var log:Log;
		public var dataLoader:DataLoader;
		
		public static function get instance():Initializer {
			if (_initializer == null) _initializer = new Initializer(new __());
			return _initializer;
		}
		
		public function Initializer(lock:__) {
			ConsecutiveFamilyTree.instance.stage.scaleMode = StageScaleMode.NO_SCALE;
			
			FilterShortcuts.init();
			ColorShortcuts.init();	
			
			ConsecutiveFamilyTree.instance.stage.addEventListener(Event.ENTER_FRAME, Utils.onFrame);
			ConsecutiveFamilyTree.instance.stage.addEventListener(Event.RESIZE, Utils.onResize);
						
			var logBack:Back = new Back();
			logBack.width = LOG_SIZE.x;
			logBack.height = LOG_SIZE.y;
			
			var windowInfo:WindowInfo = new WindowInfo(
				ConsecutiveFamilyTree.instance.stage,
				"Log...",
				logBack,
				new Close(),
				Constants.LOG_FORMAT
			);
			log = new Log(windowInfo);
			
			Keys.instance.setOn(ConsecutiveFamilyTree.instance.stage);		
			Keys.instance.addDownListener(LayerController.instance.logging, Keys.L);
			
			LayerController.instance;
			
			dataLoader = new DataLoader();
			dataLoader.addEventListener(DataLoader.DATA_LOADED, onDataLoaded);
			dataLoader.init();
		}
		
		private static const WHEEL_LIMITS:Vector3D = new Vector3D(.1, 1, 100);
		
		private static const LEVEL_NUMS:uint = 150;
		private static const LEVEL_GRID:Point = new Point(60, 75);
		private static const LEVEL_SIZE:Point = new Point(7000, 75);
		private static const LEVEL_COLORS:Array = [0x999999, 0x999999];
		private static const LEVEL_COLOR_ALPHAS:Array = [.25, .15];
		private static const LEVEL_CELL_INFO:LevelCellInfo = new LevelCellInfo(
			new Vector3D(15, 0xCCCCCC, 0),
			new Vector3D(1, 0xCCCCCC, .5)
		);
		private static const TREE_ITEM_SHIFT:uint = 15;
		private static const LEVEL_ROW_SHIFT:uint = 30;
		private static const LEVEL_ROW_MAX_NUM:uint = 3;
		
		private function onDataLoaded(e:Event):void {
			dataLoader.removeEventListener(DataLoader.DATA_LOADED, onDataLoaded);
			
			var desktopInfo:DesktopInfo = new DesktopInfo(
				ConsecutiveFamilyTree.instance.stage,
				WHEEL_LIMITS,
				LEVEL_NUMS,
				LEVEL_GRID,
				LEVEL_SIZE,
				LEVEL_COLORS,
				LEVEL_COLOR_ALPHAS,
				LEVEL_CELL_INFO,
				TREE_ITEM_SHIFT,
				LEVEL_ROW_SHIFT,
				LEVEL_ROW_MAX_NUM
			);
			Desktop.instance.desktopInfo = desktopInfo;
			
			LayerController.instance.addDesktop();
			
			var treeControllerInfo:TreeControllInfo = new TreeControllInfo(
				ConsecutiveFamilyTree.instance.stage,
				LayerController.instance,
				Desktop.instance,
				dataLoader.tree				
			);
			
			Desktop.instance.init();
			
			TreeController.draw = Number(treeControllerInfo.xml.@draw);
			TreeController.auto = Number(treeControllerInfo.xml.@auto);
			
			TreeController.instance.addEventListener(TreeController.ALL_TREE_INIT_EVENT, onInit);
			TreeController.instance.init(treeControllerInfo);
			
			LayerController.instance.initMenu();
		}
		
		private function onInit(e:Event):void {
			
		}	
	}	
}

class __ {
	
}
