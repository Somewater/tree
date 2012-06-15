package family.tree.control {
	
	import events.tree.ChangeTreeRelateDrawTypeEvent;
	
	import family.Automat;
	import family.desktop.Desktop;
	import family.item.TreeItem;
	import family.level.Level;
	import family.level.LevelCell;
	import family.tree.Tree;
	import family.tree.TreeControllInfo;
	import family.tree.TreeInfo;
	import family.tree.TreeName;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	
	import layers.control.LayerController;
	
	import menu.SortSetter;
	
	import utils.Utils;
	
	public class TreeController extends EventDispatcher {
		
		public static const ALL_TREE_INIT_EVENT:String = "AllTreeInitEvent";
		
		public static var mainTree:Tree; // Главное дерево
		public static var draw:int = -1; // Текущий режим отрисовки связей (0/простой, 1/каскадный)
		public static var auto:int = -1; // Текущий режим отображения деревьев (0/ручной, 1/автоматический)

		private static var _treeController:TreeController;
		
		private var _treeControllerInfo:TreeControllInfo;
		
		private var _trees:Array = [];
		
		private var _total:uint;
		private var _init:uint;
		
		private var _sourceTree:Tree;
		private var _copyTreeIndex:uint;
		private var _createTreeErrorController:CreateTreeErrorController;
		
		public function TreeController(lock:__) {
			_treeController = this;
		}
		
		public static function get instance():TreeController {
			if (_treeController == null) _treeController = new TreeController(new __());
			return _treeController;
		}
		
		/** Есть ли такой UID среди UIDs... */
		public static function isUID(uid:uint, uids:Array):Boolean {
			for (var i:uint = 0; i < uids.length; i++) if (uids[i] == uid) return true;
			return false;
		}	
		
		/** Стереть данные об этом дереве в клетка, относимыс с его TreeItems... */
		/** Но сохранить данные о позиции и уровне... */
		public static function deleteTreeItemsFromTheresLevelCells(tree:Tree):void {
			var treeItem:TreeItem;
			var level:Level;
			var levelCell:LevelCell;
			for (var i:uint = 0; i < tree.treeItems.length; i++) {
				treeItem = tree.treeItems[i];
				
				level = Desktop.instance.getLevelByUID(treeItem.level);
				levelCell = level.getLevelCellByCellPos(treeItem.pos);
				
				if (levelCell) { // Если этот ряд еще не успел закрыться...				
					treeItem.oldPos = treeItem.pos;
					treeItem.oldLevel = treeItem.level;
					
					levelCell.treeItem = null;
				}
			}			
		}
		
		public function get treeControllerInfo():TreeControllInfo { return _treeControllerInfo; }
		public function get trees():Array { return _trees; }
		
		public function init(treeControllerInfo:TreeControllInfo):void {
			_treeControllerInfo = treeControllerInfo;
			
			if (auto) { // Автопостроение - когда не известны pos(ряд, номер ячейки)... 
				Automat.instance.tryAutoSetTrees();
			} else { // Простая ручная установка...
				// Строим деревья...
				var treeInfo:TreeInfo;
				var tree:Tree;
				for each (var t:XML in _treeControllerInfo.xml.elements()) {
					treeInfo = new TreeInfo(this, t);
					tree = new Tree(treeInfo);
					_trees.push(tree);
				}
				
				// Инициализация деревьев...
				_total = _trees.length;
				for (var i:uint = 0; i < _trees.length; i++) {
					tree = _trees[i];
					tree.addEventListener(Tree.TREE_INIT_EVENT, onTreeInit);
					if (!i) mainTree = tree; // Определяем главное дерево...
					tree.init();
				}
			}			
		}
		
		// Узнать принадлежит ли эта клетка какой-либо клетки какому-либо дерева по его боундинг боксу (exept не обрабатывать)...
		public function isLevelCell(levelCell:LevelCell, except:Tree):Boolean {
			var tree:Tree;
			var cells:Array;
			
			var levelUID:uint = levelCell.level.uid;
			var x:uint = levelCell.pos.x;
			var y:uint = levelCell.pos.y;
			
			var cell:LevelCell;
			
			var exceptTreeUID:uint = except.uid;
			
			for (var i:uint = 0; i < _trees.length; i++) {
				tree = _trees[i];
				cells = tree.border.allTreeLevelCells;
				if (tree.uid != exceptTreeUID) {
					for (var j:uint = 0; j < cells.length; j++) {
						cell = cells[j];
						if (cell.level.uid == levelUID && cell.pos.x == x && cell.pos.y == y) return true;
					}
				}
			}
			return false;
		}
		
		public function isTreeNameExist(treeName:TreeName):Boolean {
			for(var i:uint = 0; i < _trees.length; i++) if (Tree(_trees[i]).treeName == treeName) return true;
			return false;
		}
		
		/** Создать копию дерева при перемещении... */
		/** Если вернется ошибка, то обработать ее... */
		public function copyTree(sourceTree:Tree, xml:XML):void {
			LayerController.instance.removeFromTreeLayer(sourceTree);
			deleteTreeItemsFromTheresLevelCells(sourceTree);
			
			// Не удаляем дерево-исходник с экрана, пока идет копирование и вставка -
			// вдруг копирование или вставка вызовет ошибку - тогда мы вернем дерево-исходник...
			
			_sourceTree = sourceTree;
			_copyTreeIndex = _trees.indexOf(sourceTree);
			
			var treeInfo:TreeInfo = new TreeInfo(this, xml);
			var newTree:Tree = new Tree(treeInfo);
			
			_trees[_copyTreeIndex] = newTree;
			mainTree = _trees[0];
			
			_createTreeErrorController = new CreateTreeErrorController(newTree);
			_createTreeErrorController.addEventListener(CreateTreeErrorController.ERROR_EVENT, onCopyTreeError);
			_createTreeErrorController.addEventListener(CreateTreeErrorController.SUCCESS_EVENT, onCopyTreeSuccess);
			_createTreeErrorController.init();
		}
		
		/** Получить количество строк в уровне, в зависисмости от TreeItem с самым большим значением... */
		public function getTreeItemMaxRowPosByLevel(level:uint):int {
			// Пробегаюсь по всем деревьям и выясняю максимальное количество рядов в уровне...
			// Операция должна быть быстрой, так как основывается на цифрах, тем более, что далеко не на каждом уровне есть TreeItems
			var maxRow:int = -1;
			var rows:int;
			var tree:Tree;
			for (var i:uint = 0; i < _trees.length; i++) {
				tree = _trees[i];
				rows = tree.getTreeItemMaxRowPosByLevel(level);
				if (rows > maxRow) maxRow = rows;
			}
			return maxRow;
		}
		
		/** Меняем тип отрисовки */
		public function changeRelateDrawType(type:uint):void {
			var tree:Tree;
			for (var i:uint = 0; i < _trees.length; i++) {
				tree = _trees[i];
				tree.dispatchEvent(
					new ChangeTreeRelateDrawTypeEvent(
						ChangeTreeRelateDrawTypeEvent.CHANGE_TREE_RELATE_DRAW_TYPE_EVENT,
						false,
						false,
						type
					)
				);
			}
		}
		
		/** Меняем тип сортировки */
		public function changeSortType():void {
			var tree:Tree;
			for (var i:uint = 0; i < _trees.length; i++) {
				tree = _trees[i];
				tree.dispatchEvent(new Event(SortSetter.CHANGE_TREE_SORT_TYPE_EVENT));
			}
		}
		
		public function update():void {
			Desktop.instance.update();
			showTrees();
			try {
				LayerController.instance.menuLayer.menuInstance.update();
			} catch (e:Error){
				
			}			
		}
		
		public function showTrees():void {
			var tree:Tree;
			for (var i:uint = 0; i < _trees.length; i++) {
				tree = _trees[i];
				LayerController.instance.addToTreeLayer(tree);
				tree.update();
			}
		}
		
		public function hideTrees():void {
			var tree:Tree;
			for (var i:uint = 0; i < _trees.length; i++) {
				tree = _trees[i];
				LayerController.instance.removeFromTreeLayer(tree);
			}
		}
		
		// Удаление ряда из уровня должно сопровождаться попыткой сместить все TreeItem всех Tree на ряд выше...
		// Если смещение прошло корректно, то позволяем удалить ряд из этого уровня...
		public function tryRemoveLevelRow(level:Level):void {
			if (Automat.instance.tryShiftTreeItemInLevelRowUp(level)) {
				level.canRemoveRow();
				update();
			}
		}
		
		// Сталкивается ли это дерево с другими деревьями...
		public function isIntersect(tree:Tree):Boolean {
			var t:Tree;
			for (var i:uint = 0; i < TreeController.instance.trees.length; i++) {
				t = TreeController.instance.trees[i];
				if (t.uid != tree.uid && t.hitTestObject(tree)) return true; 
			}
			return false;
		}
		
		private function deleteCreateTreeErrorController():void {
			_createTreeErrorController.removeEventListener(CreateTreeErrorController.ERROR_EVENT, onCopyTreeError);
			_createTreeErrorController.removeEventListener(CreateTreeErrorController.SUCCESS_EVENT, onCopyTreeSuccess);
			_createTreeErrorController = null;
		}
		
		private function onCopyTreeError(e:Event):void {
			// Убить дерево которое не смогло спозиционироваться по какой-либо ошибке...
			var copy:Tree = _trees[_copyTreeIndex];
			LayerController.instance.removeFromTreeLayer(copy);
			copy.dispose();
			
			// Ставим прошлое дерево которое не смогло скопироваться и встать на новое место...
			_trees[_copyTreeIndex] = _sourceTree;
			mainTree = _trees[0];
			
			LayerController.instance.addToTreeLayer(_sourceTree);
			
			Desktop.instance.closeAllEmptyLevels();
			update();			
			
			Utils.showReport(Constants.CREATE_TREE_ERRORS[_createTreeErrorController.error]);
			
			deleteCreateTreeErrorController();
		}
		
		private function onCopyTreeSuccess(e:Event):void {
			deleteCreateTreeErrorController();
			_sourceTree.dispose();
			update();
		}
		
		private function onTreeInit(e:Event):void {
			e.target.removeEventListener(Tree.TREE_INIT_EVENT, onTreeInit);
			_init++;
			if (_init == _total) {
				dispatchEvent(new Event(ALL_TREE_INIT_EVENT));
				showTrees();
			}
		}	
	}
}

class __ {
	
}