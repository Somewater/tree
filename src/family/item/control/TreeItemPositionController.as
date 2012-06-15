package family.item.control {
	
	import family.desktop.Desktop;
	import family.item.TreeItem;
	import family.level.Level;
	import family.level.LevelCell;
	import family.relation.Union;
	import family.tree.Tree;
	import family.tree.control.TreeController;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	
	import utils.Utils;
	
	public class TreeItemPositionController extends EventDispatcher implements IUpdate {
		
		public static const TARGET_LEVEL_CELL_FULL_ERROR_EVENT:String = "TargetLevelCellFullErrorEvent";
		
		private var _tree:Tree;
		
		private var _dragLevel:Level; // Уровень в котором сейчас таскаеются TreeItems...
		private var _allDragTreeItems:Array; // Все таскаемые TreeItems...
		private var _allDragSourceLevelCells:Array; // Исходные ячейки из которых вытащили TreeItems...
		private var _allTargetLevelCell:Array; // Целевые посвечеваемые ячейки...
		
		public function TreeItemPositionController(tree:Tree) {
			_tree = tree;
		}
		
		/** Подсветить ближайшие LevelCell по реальным координатам TreeItem */
		public function lightLevelCell(treeItemDragController:TreeItemDragController):void {
			
			var i:uint;
			var cell:LevelCell;
			var unionTreeItems:Array;
			var item:TreeItem;
			
			if (_dragLevel == null) {
				_allDragTreeItems = [];
				_allDragSourceLevelCells = [];
				
				_dragLevel = Desktop.instance.getLevelByUID(treeItemDragController.treeItem.level);
				
				item = treeItemDragController.treeItem;
				cell = Desktop.instance.getLevelCellByItem(item)[1];
				_allDragTreeItems.push(item);
				cell.treeItem = null; // При таскании в LevelTree как бы уже нет таскаемого TreeItem...
				
				_allDragSourceLevelCells.push(cell);
				if (treeItemDragController.union) {
					unionTreeItems = treeItemDragController.union.unions;
					for (i = 0; i < unionTreeItems.length; i++) {
						item = unionTreeItems[i];
						cell = Desktop.instance.getLevelCellByItem(item)[1];
						_allDragSourceLevelCells.push(cell);
						
						_allDragTreeItems.push(item);
						
						cell.treeItem = null; // При таскании в LevelTree как бы уже нет таскаемого TreeItem...
					}
				}
			}
			
			resetLigts();
			_allTargetLevelCell = []
			
			var p:Point;
			var cellPos:Point;
			for (i = 0; i < _allDragTreeItems.length; i++) {
				item = _allDragTreeItems[i];
				_tree.addChild(item);
				p = new Point(
						item.x,
						item.y
					);
				cellPos = _dragLevel.getLevelCellPosByPos(p);
				cell = _dragLevel.getLevelCellByCellPos(cellPos);
				if (cell) {
					_allTargetLevelCell.push(cell);
					cell.light();
				}
			}
		}
		
		public function stopDrag():void {
			resetLigts();
			
			var length:Boolean = true;			
			if (_allTargetLevelCell.length != _allDragTreeItems.length) length = false;
			
			var valid:Boolean = isValid();
		
			// Возвращаем обратно TreeItems в sourceLeveCells, если...
			// Хоть одна целевая ячейка занята...
			// Мы у края...
			if (!length || !valid) {
				setTreeItemsToCells(_allDragSourceLevelCells);
				Utils.showReport(Constants.REPORT_1);
			} else {
				setTreeItemsToCells(_allTargetLevelCell); // Ставим TreeItems в targetLevelCells...
				
				// Проверяем не пересекаются ли деревья, от этой вставки...
				var intersect:Boolean = TreeController.instance.isIntersect(_tree);
				if (intersect) {
					setTreeItemsToCells(_allDragSourceLevelCells);
					Utils.showReport(Constants.REPORT_2);
				}			
			}
			
			_dragLevel = null;
			_allDragSourceLevelCells = null;
			_allTargetLevelCell = null;
			_allDragTreeItems = null;
		}
		
		private function resetLigts():void {
			if (_allTargetLevelCell == null) return;
			var cell:LevelCell;
			for (var i:uint = 0; i < _allTargetLevelCell.length; i++) {
				cell = _allTargetLevelCell[i];
				cell.unLight();
			}			
		}
		
		// Есть ли хоть одна занятая целевая клетка...
		// Есть ли между ячейками еще одна ячейка влево/вправо относительно других ячеек...
		private function isValid():Boolean {
			var distance:uint;
			
			var cell:LevelCell;
			var cell_:LevelCell;
			
			var left:LevelCell;
			var right:LevelCell;
			
			var p:Point;
			
			for (var i:uint = 0; i < _allTargetLevelCell.length; i++) {
				cell = _allTargetLevelCell[i];
				if (cell.treeItem) return false;
				
				for (var j:uint = 0; j < _allTargetLevelCell.length; j++) {
					cell_ = _allTargetLevelCell[j];
					if (cell != cell_) {
						distance = Math.abs(cell_.pos.y - cell.pos.y);
						if (distance < 2) return false; // Таскается пара...
					}
				}
				
				p = cell.pos;
				left = _dragLevel.getLevelCellByCellPos(new Point(p.x, p.y - 1));
				right = _dragLevel.getLevelCellByCellPos(new Point(p.x, p.y + 1));
				if (left) if (left.treeItem) return false;
				if (right) if (right.treeItem) return false;
				
			}
			return true;
		}
			
		private function setTreeItemsToCells(cells:Array):void {
			var cell:LevelCell;
			var cellFrom:LevelCell;
			var item:TreeItem;
			for (var i:uint = 0; i < _allDragTreeItems.length; i++) {
				item = _allDragTreeItems[i];
				cellFrom = _dragLevel.getLevelCellByCellPos(item.pos);
				cell = cells[i];
				
				item.x = _dragLevel.x + cell.x;
				item.y = _dragLevel.y + cell.y;
				item.pos = cell.pos.clone();
				
				// Ставим перед установкой treeItem, так как есть еще вариант, когда TreeItem возвращается обратно в свою LeveleCell...
				// Если эту строку поставить после cell.treeItem = item, то при возвращении TreeItem на свое сиходное место данные о нем в LevelCell затруться на null...
				cellFrom.treeItem = null;
				
				cell.treeItem = item; // Теперь в этой ячейке находится этот TreeItem...
			}
			_tree.renew();
		}
		
		/** Интерфейс */
		
		/** Пересчитываем и задаем реальные координаты TreeItem, на оснавании их клеточных позиций */ 
		public function update():void {
			var _treeItems:Array = _tree.treeItems;
		
			var treeItem:TreeItem;
			
			var arr:Array;
			var level:Level;
			var levelCell:LevelCell;
			
			for (var i:uint = 0; i < _treeItems.length; i++) {
				treeItem = _treeItems[i];
				
				arr = Desktop.instance.getLevelCellByItem(treeItem);
				level = arr[0];
				levelCell = arr[1];
				
				// Если levelCell = null, значит не создан ряд в уровне - необходимо его создать - этого не нужно
				// делать при первой инициализации, но при копировании деревьев и их перемещении - необходимо...
				if (levelCell == null) {
					var k:uint = treeItem.pos.x;
					while(level.k < k) level.onPlusClick(null);
					
					arr = Desktop.instance.getLevelCellByItem(treeItem);
					level = arr[0];
					levelCell = arr[1];
				}
				
				treeItem.x = level.x + levelCell.x;
				treeItem.y = level.y + levelCell.y;
				
				// Теперь ячейка знает, какой TreeItem стоит в ней...
				levelCell.treeItem = treeItem;
			}
		}
	}
}