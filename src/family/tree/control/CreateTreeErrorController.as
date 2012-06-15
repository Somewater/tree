package family.tree.control {
	
	import family.desktop.Desktop;
	import family.item.control.TreeItemPositionController;
	import family.tree.Tree;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import layers.control.LayerController;
	
	public class CreateTreeErrorController extends EventDispatcher implements IUse {
		
		/** Этот класс создан специально, чтобы в него стикались все возможные ошибки при создании и вставки деревьев */
		/** Ошибки создания деревьев и их кописровани могут быть различными, основываясь на TreeItem, инициализации, связей, столкновений и т.д. */
		
		public static const ERROR_EVENT:String = "ErrorEvent";
		public static const SUCCESS_EVENT:String = "SuccessEvent";
		
		private static const TARGET_LEVEL_CELL_FULL_EVENT:uint = 0;
		private static const INTERSECT_TREE:uint = 1;
		private static const TREE_AUTO_CREATE_EVENT:uint = 2;
		
		public var error:int = -1;
		
		private var _tree:Tree;
		
		public function CreateTreeErrorController(tree:Tree) {
			_tree = tree;
		}
		
		private function onInit(e:Event):void {
			removeAllListeners();
			
			LayerController.instance.addToTreeLayer(_tree);
			
			TreeController.instance.update();
			Desktop.instance.closeAllEmptyLevels();
			TreeController.instance.update();
			
			// Проверяем не столкнулись ли деревья после вставки...
			var intrsect:Boolean = TreeController.instance.isIntersect(_tree);
			
			if (!intrsect) {
				dispatchEvent(new Event(SUCCESS_EVENT));
			} else {
				error = INTERSECT_TREE;
				dispatchEvent(new Event(ERROR_EVENT));
			}
		}
		
		private function onTargetLevelCellFull(e:Event):void {
			removeAllListeners();
			
			error = TARGET_LEVEL_CELL_FULL_EVENT;
			dispatchEvent(new Event(ERROR_EVENT));
		}
		
		private function onTreeAutoCreate(e:Event):void {
			removeAllListeners();
			
			error = TREE_AUTO_CREATE_EVENT;
			dispatchEvent(new Event(ERROR_EVENT));
		}
		
		private function removeAllListeners():void {
			_tree.removeEventListener(Tree.TREE_INIT_EVENT, onInit);
			_tree.positionController.removeEventListener(TreeItemPositionController.TARGET_LEVEL_CELL_FULL_ERROR_EVENT, onTargetLevelCellFull);
			_tree.removeEventListener(Tree.TREE_AUTO_CREATE_ERROR_EVENT, onTreeAutoCreate);
		}
		
		/** Интерфейс */
		
		public function init():void {
			_tree.addEventListener(Tree.TREE_INIT_EVENT, onInit);
			_tree.positionController.addEventListener(TreeItemPositionController.TARGET_LEVEL_CELL_FULL_ERROR_EVENT, onTargetLevelCellFull);
			_tree.addEventListener(Tree.TREE_AUTO_CREATE_ERROR_EVENT, onTreeAutoCreate);
			_tree.init();
		}
		
		public function update():void {
		
		}
	}
}