package family.item.control {

	import family.Automat;
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
	
	public class TreeItemAutoPositionController extends EventDispatcher implements IUse,IDisposable {
		
		public static const ERROR_EVENT:String = "ErrorEvent";
		public static const SUCCESS_EVENT:String = "SuccessEvent";
		
		private var _tree:Tree;
				
		public function TreeItemAutoPositionController(tree:Tree) {
			_tree = tree;
		}	
		
		/** Интерфейс */
		
		// По сути, если мы вошли в этот метод, то дерево которое автоматически
		// пытается разместиться, уже на сцене, только все позиции TreeItem.pos
		// равны tree.periodCell.pos, но все связи уже построены и Unions определены
		// Осталось лишь попытаться разместить все TreeItems 
		public function init():void {
			var _treeItems:Array = _tree.treeItems;
			
			var treeItem:TreeItem;
			
			var level:Level;
			var levelCell:LevelCell;
			var checkUIDs:Array = [];
			var targetTreeItems:Array;
			var presentPartnerUinion:Union;
			var cells:Array;
			var t:TreeItem;
			var freeCells:Array;
			var p:Point;
			var arr:Array;
			var tt:TreeItem;
			var lc:LevelCell;
			
			for (var i:uint = 0; i < _treeItems.length; i++) {
				treeItem = _treeItems[i];
				
				// Может мы уже проверяли этот TreeItem в PresentPartnerUnion...
				if (TreeController.isUID(treeItem.uid, checkUIDs)) continue;
				
				level = Desktop.instance.getLevelByUID(treeItem.level);
				
				// Сдесь пытаемся подобрать позицию для TreeItem или его Union
				// Если подобрали позицию, то размещаем TreeItem(s) и сохраняем ссылку(ссылки) на него(них) в соответствующих TreeItem 
				// Если произошла ошибка и место не подобралось (ряд в уровне полностью забит), то останвливаемся и выдаем ошибку
				
				targetTreeItems = [];
				
				// Узнаем, может быть этот TreeItem нужно перемещать с другим неотделимым TreeItem (например, ParentUnion)...
				presentPartnerUinion = treeItem.tree.relationController.getPresentPartnerUnion(treeItem);
				
				if (presentPartnerUinion) {
					targetTreeItems.push(presentPartnerUinion.parent);
					targetTreeItems.push(presentPartnerUinion.unions[0]);
				} else {
					targetTreeItems.push(treeItem);
				}
				
				cells = [];
				for (var j:uint = 0; j < targetTreeItems.length; j++) {
					t = targetTreeItems[j];
					
					p = _tree.periodCell.pos.clone();
					
					if (!j) { 
						cells.push(p);
					} else { // Если второй родственник, то указать ему стартовую позицию на 2 клетки смещения вправо
						p.y = p.y + 2;
						cells.push(p);
					}
					
					checkUIDs.push(t.uid);
				}
				
				freeCells = level.getEmptyCellNearCell(0, cells);
				
				// Ошибка поиска свободных клеток на ряд выше (кончилось количество ячеек в ряду или нет возможности распередлить TreeItem без искажения главных целей)...
				if (freeCells == null) {
					dispatchEvent(new Event(ERROR_EVENT));
					return;
				}
				
				arr = freeCells[Automat.TO_LEFT];
				
				// Влево...
				if (arr) {
					for (var l:uint = 0; l < arr.length; l++) {
						TreeItem(targetTreeItems[l]).pos = LevelCell(arr[l]).pos.clone();
					}
				}
				
				// Вправо...
				if (!arr) {
					for (var r:uint = 0; r < arr.length; r++) {
						TreeItem(targetTreeItems[r]).pos = LevelCell(arr[r]).pos.clone();
					}
				}
				
				for (var z:uint = 0; z < arr.length; z++) {
					tt = TreeItem(targetTreeItems[z]);
					lc = LevelCell(arr[z]);
				
					tt.x = level.x + lc.x;
					tt.y = level.y + lc.y;
				
					// Теперь ячейка знает, какой TreeItem стоит в ней...
					lc.treeItem = tt; 
				}				
			}
			
			dispatchEvent(new Event(SUCCESS_EVENT));
		}
		
		public function update():void {
			
		}
		
		public function dispose():void {
			// Стираем всю информацию о TreeItems этого дерева, так как автопозиционирование не увеняалось успехом...
			var treeItem:TreeItem;
			var level:Level;
			var levelCell:LevelCell;
			for (var i:uint = 0; i < _tree.treeItems.length; i++) {
				treeItem = _tree.treeItems[i];
				level = Desktop.instance.getLevelByUID(treeItem.level);
				levelCell = level.getLevelCellByCellPos(treeItem.pos);
				levelCell.treeItem = null;
			}
		}
	}
}