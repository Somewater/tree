package family {
	
	import family.desktop.Desktop;
	import family.item.TreeItem;
	import family.level.Level;
	import family.level.LevelCell;
	import family.relation.Union;
	import family.tree.Tree;
	import family.tree.TreeInfo;
	import family.tree.control.CreateTreeErrorController;
	import family.tree.control.TreeController;
	
	import flash.events.Event;
	import flash.geom.Point;
	
	import layers.control.LayerController;
	
	import utils.Utils;
	
	public class Automat {
		
		public static const TO_LEFT:uint = 0;
		public static const TO_RIGHT:uint = 1;
				
		private static var _automat:Automat;
		
		public function Automat(lock:__) {
			_automat = this;
		}
		
		public static function get instance():Automat {
			if (_automat == null) _automat = new Automat(new __());
			return _automat;
		}
		
		/** Попытка удаление ряда в уровне */		
		
		public function tryShiftTreeItemInLevelRowUp(level:Level):Boolean {
			var i:uint;
			var j:uint;	
			var k:uint;
			var n:uint;
			
			// Получаем все TreeItem данного уровня данного ряда...
			var allTreeItems:Array = [];
			var tree:Tree;
			var arr:Array;
			var a:Array;
			var res:Array = [];
			
			var freeCells:Array;
			var treeItem:TreeItem;
			var targetTreeItems:Array;
			var presentPartnerUinion:Union;
			var cells:Array;
			var checkUIDs:Array;
			
			for (i = 0; i < TreeController.instance.trees.length; i++) {
				tree = TreeController.instance.trees[i];
				arr = tree.getAllTreeItemsByLevelAndRow(level, level.k);
				if (arr) allTreeItems.push(arr);
			}
			
			if (!allTreeItems.length) return true; // Никаких TreeItem вообще нет в этом уровне и в этом ряду...
			
			// Если ряд на который хотим поднять айтемы < 0, то запрещаем...
			var targetRow:int = level.k - 1;
			if (targetRow < 0) return false;
			
			// Сохраняем старые координаты клеток TreeItems - перед определением их на верхний уровень...
			// Это необходим, чтобы вернуть айтемы в исходные места, если произойдет ошибка определения их по свободным ячейкам верхнего ряда...
			for (i = 0; i < allTreeItems.length; i++) {
				a = allTreeItems[i];
				for (j = 0; j < a.length; j++) {
					treeItem = allTreeItems[i][j];
					treeItem.oldPos = treeItem.pos.clone();
					res.push(treeItem);
				}				
			}
			
			checkUIDs = [];
			var t:TreeItem;
			var tt:TreeItem;
			var levelCell:LevelCell;
			var oldLevelCell:LevelCell;
			
			// Пытаемся расположить айтемы на уровень выше...
			for (i = 0; i < res.length; i++) {
				treeItem = res[i];
				
				// Может мы уже проверяли этот TreeItem в PresentPartnerUnion...
				if (TreeController.isUID(treeItem.uid, checkUIDs)) continue;
				
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
				for (j = 0; j < targetTreeItems.length; j++) {
					t = targetTreeItems[j];
					cells.push(t.pos.clone());
					checkUIDs.push(t.uid);
				}
				
				freeCells = level.getEmptyCellNearCell(targetRow, cells);
				
				function returnAll():void {
					// Вернуть все уже передвинутые TreeItems в старые места, так как произошла ошибка подбора свободных мест для TreeItems...
					for (n = 0; n < targetTreeItems.length; n++) {
						t = targetTreeItems[n];	
						if (t.pos.x != t.oldPos.x || t.pos.y != t.oldPos.y) { // Этот TreeItem уже успел переместиться - его нужно вернуть обратно...
							levelCell = level.getLevelCellByCellPos(t.pos);
							oldLevelCell = level.getLevelCellByCellPos(t.oldPos);
						
							// Удаляем из новой ячейки этот TreeItem...
							levelCell.treeItem = null;
							
							t.pos = t.oldPos.clone();
							oldLevelCell.treeItem = t;
							
							t.x = oldLevelCell.x;
							t.y = oldLevelCell.y;
						}						
					}
				}
				
				// Ошибка поиска свободных клеток на ряд выше (кончилось количество ячеек в ряду или нет возможности распередлить TreeItem без искажения главных целей)...
				if (freeCells == null) {
					returnAll();
					return false;
				}
				
				// Свободные клетки нашлись!
				// Втавляем эти TreeItems в эти клетки и продолжаем поиск...
				// Но если при вставке деревья пересеклись, попытаться попробовать поставить в другую сторону...
				// Если попытка вставки айтемов влево или вправо все же не удалась, вернуть все на свои места...
				
				function trySet(arr:Array):Boolean {
					for (k = 0; k < targetTreeItems.length; k++) {
						tt = targetTreeItems[k]; // Перемещаемый TreeItem
						
						levelCell = arr[k]; // Целевая ячейка
						
						// Удаляем из прошлой ячейки этот TreeItem...
						LevelCell(level.getLevelCellByCellPos(tt.pos)).treeItem = null;
						
						// Теперь TreeItem поставлен в целевую свободную клетку LevelCell, которую ему определил алгоритм расчета...
						tt.pos = levelCell.pos.clone();
						levelCell.treeItem = tt;
						
						tt.x = levelCell.x;
						tt.y = levelCell.y;
						
						treeItem.tree.border.update();
						
						var intersect:Boolean = TreeController.instance.isIntersect(treeItem.tree);
						
						if (intersect) return false;
					}
					return true;
				}
				
				var result:Boolean = false;
				
				// Влево...
				if (freeCells[TO_LEFT]) {
					result = trySet(freeCells[TO_LEFT]);
				}
					
				// Вправо...
				if (!result) {
					if (freeCells[TO_RIGHT]) {
						result = trySet(freeCells[TO_RIGHT]);
					}
				}
				
				if (!result) { // Все попытки не удались...
					returnAll();
					return false;
				}
			}
			
			return true;
		}
		
		/** Попытка перемещения дерева */
		
		public function tryMoveTree(treeDragController:DragController):void {
			var targetLevel:Level = treeDragController.dropTargetLevel;
			var targetCell:LevelCell = treeDragController.dropTargetLevelCell;
			
			var tree:Tree = Tree(treeDragController.object);
			
			var mainTreeItem:TreeItem = tree.treeItems[0];
			
			var sourceLevel:Level;
			var dr:uint; // На сколько нужно увеличить количество рядов в целевом уровне...
			
			var i:uint;
			
			var findCellPos:Point;
			var findCell:LevelCell;
			
			var sharpCellPos:Point;
			var sharpCell:LevelCell;
			
			function cancel():void {
				Desktop.instance.closeAllEmptyLevels();
				tree.update();
				Utils.showReport(Constants.REPORT_4);
			}
			
			var mouse:Point;
			var targetPoint:Point;
			
			if (targetLevel == null && targetCell == null) { // Попали на любой объект, но не тот что необходим...
				tree.update();
				Utils.showReport(Constants.REPORT_3);
			} else {
				function prepareLevel():void {
					// Если уровень пустой, то его нужно открыть и найти ближайшую клетку...
					// Если уровень не пустой, то сразу найти ближайшую клетку...
					
					sourceLevel = Desktop.instance.getLevelByUID(mainTreeItem.level);
					
					if (targetLevel.k == -1) {
						// Добавляем столько же рядов в уровень, какого уровня главный mainTreeItem...
						for (i = 0; i <= mainTreeItem.pos.x; i++) targetLevel.onPlusClick(null);
					} else if (targetLevel.k < mainTreeItem.pos.x){
						dr = mainTreeItem.pos.x - targetLevel.k;
						for (i = 0; i < dr; i++) targetLevel.onPlusClick(null);
					}
				}
				
				function moveTo(pos:Point):void {
					// Находим точную клетку, от которой будет строится дерево...
					sharpCellPos = pos;
					sharpCellPos.x = mainTreeItem.pos.x;
					
					sharpCell = targetLevel.getLevelCellByCellPos(sharpCellPos);
					
					// Если эта клетка занята, то отменить перетаскивание дерева...
					if (sharpCell == null || sharpCell.treeItem) {
						cancel();
						return;
					}
					
					tryMoveTreeToTargetCell(Tree(treeDragController.object), sharpCell);		
				}
								
				if (targetCell) {
					
					// Если эта клетка занята, то отменить перетаскивание дерева...
					if (targetCell.treeItem) {
						cancel();
						return;
					}
					targetLevel = Desktop.instance.getLevelByUID(targetCell.level.uid);
					
					prepareLevel();
					
					moveTo(targetCell.pos);
					
				} else if (targetLevel) {
					mouse = new Point(targetLevel.mouseX, targetLevel.mouseY);
					
					prepareLevel();
					
					// Находим примерную клетку куда нужно ставить дерево - исходную под главный mainTreeItem...
					
					// Пересчитываем целевую точку, уже относительно открытого уровня...
					targetPoint = new Point(mouse.x, targetLevel.y + mouse.y + Desktop.instance.desktopInfo.levelRowShift);
					
					findCellPos = targetLevel.getLevelCellPosByPos(targetPoint);
					findCell = targetLevel.getLevelCellByCellPos(findCellPos);
					
					moveTo(findCellPos.clone());
				}
			}
			
			treeDragController.dispose();
		}
		
		private function tryMoveTreeToTargetCell(tree:Tree, cell:LevelCell):void {
			// Получаю текущую XML дерева...
			var xml:XML = new XML(tree.treeInfo.xml);
			
			// Перестраиваю ее под новое место...
			xml.@["level"] = cell.level.uid.toString();
			
			var uid:uint;
						
			var p:Array;
			
			var pos:Point;
			var newPos:Point;
			
			var counter:uint;
			
			var oldMainPos:Point;
			var newMainPos:Point = cell.pos.clone();
			
			for each (var r:XML in xml.elements()) {
				p = String(r.@pos).split(",");
				pos = new Point(uint(p[0]), uint(p[1]));
				
				if (!counter) { // Главный узел...
					oldMainPos = pos.clone();
					r.@["pos"] = newMainPos.x + "," + newMainPos.y;
				} else {
					// Ряд остается, а вот позиция в ряду меняется...
										
					var resPos:Point = new Point();
					resPos.x = pos.x;
					
					var dY:int = pos.y - oldMainPos.y;
					resPos.y = newMainPos.y + dY;
					
					if (resPos.y < 0 || resPos.y >= Desktop.instance.desktopInfo.levelCellNums) {
						Utils.showReport(Constants.REPORT_4);
						return;
					}
					
					r.@["pos"] = resPos.x + "," + resPos.y;
				}
				
				counter++;
			}	
			// Пытаемся переставить дерево в новое место...
			// Если при вставке дерева, в какой либо клетке обнаружиться TreeItem, то прекращаем вставку дерева...
			// Если при вставке дерева, целевые клетки не существуют (края десктопа), то прекращаем вставку дерева...
			// Если после вставки дерева, это дерево пересекается с каким-либо другим деревом, то прекращаем вставку дерева...
			TreeController.instance.copyTree(tree, xml);
		}		
		
		/** Попытка автоматической расстановки всех деревьев по спирали */	
		/** Открываем все уровни только на 1 ряд */
		/** Если в процессе вставки деревьев какой-либо ряд забивается, то открываем второй ряд, а может быть и даже третий */
		/** Начинаем пытаться установливать деревья, по спирали из центра десктопа (центральной LevelCell) */
		/** Если клетка входит в занятые клетки других уже вставленных деревьев, то проверяем следующую клетку */
		/** Если клетка не входит в занятые клетки боундинг бокса никакого дерева, то пытаемся построить дерево, начиная с этой клетки */
		/** Если при вставке дерева произошла ошибка, продолжаем пытаться вставить дерево сново в следующую клетку по спирали */
		
		/** Потом попробовать ускорить алгоритм так: если дерево построилось полностью как надо, но столкнулось при вставке с другим деревом,
		 * то заново его не создаем, а просто пытаемся подыскать для него другую позицию, исследуя следующие клетки по спирали */ 
		public function tryAutoSetTrees():void {
			_treeTotal = TreeController.instance.treeControllerInfo.xml.tree.length();
			if (!_treeTotal) return; // Нечего строить, выходим...
			
			Desktop.instance.openAllLevelsForRow(0);
			
			_treeCounter = 0;
			_treeXML = TreeController.instance.treeControllerInfo.xml.tree[_treeCounter];
			
			_centerCell = Desktop.instance.getCenterLevelCell(); // Клетка-точка-отсчета от которой начинается поиск...
			
			reset();
			start();
		}
		
		private var _centerCell:LevelCell;
		private var _period:Array; // Клетки по квадрату по часовой стрелки от клетки-точки-отсчета...
		
		private var _periodCounter:uint; // Текущий период
		
		private var _periodCellCounter:uint; // Текущая проверяемая клетка текущего периода
		private var _periodCellTotal:uint; // Текущее количество клеток текущего периода
		
		private var _treeCounter:uint;
		private var _treeTotal:uint;
		private var _treeXML:XML;
		
		private var _createTreeErrorController:CreateTreeErrorController;
		
		private var _periodCell:LevelCell;
		
		private function reset():void {
			_periodCounter = _periodCellCounter = 0;
			_period = [];
			_period.push(_centerCell);
		}
		
		private function start():void {
			_periodCellTotal = _period.length;
			_periodCell = _period[_periodCellCounter];
			tryCreateAutoTree();			
		}
		
		private var _tree:Tree; // Текущее создаваемое дерево в автоматическом режиме...
		
		/** Попытаться создать и разместить автоматическое дерево - когда позиции узлов не известны, но известна клетка осчета */
		private function tryCreateAutoTree():void {
			var treeInfo:TreeInfo = new TreeInfo(TreeController.instance, _treeXML);
			_tree = new Tree(treeInfo, _periodCell);
			
			_createTreeErrorController = new CreateTreeErrorController(_tree);
			_createTreeErrorController.addEventListener(CreateTreeErrorController.ERROR_EVENT, onError);
			_createTreeErrorController.addEventListener(CreateTreeErrorController.SUCCESS_EVENT, onSuccess);
			_createTreeErrorController.init();
		}
		
		private function onError(e:Event):void {
			// Полностью удаляем дерево, которое не удолось разместить относительно текущей LevelCell
			deleteCreateTreeErrorController();
			_tree.dispose();
			_tree = null;
			
			// Беру следующую клетку на обработку
			_periodCellCounter++;			
			_periodCell = _period[_periodCellCounter];
			
			if (_periodCell == null) { // Клетки в периоде кончились - берем следующий массив периода
				_periodCounter++;
				_period = Desktop.instance.getSpiralCellPeriod(_centerCell, _periodCounter);
				_periodCellCounter = 0;
				start();
			} else {
				tryCreateAutoTree();
			}
		}
		
		private function onSuccess(e:Event):void {
			deleteCreateTreeErrorController();
			
			// Официально сохраняем дерево, которое установилось в общий массив...
			TreeController.instance.trees[_treeCounter] = _tree;
			_tree = null; // Убиваем ссылку на это дерево в данном классе...
			TreeController.instance.update(); // Обновляем и показываем построенные деревья
			
			_treeCounter++;
			
			if (_treeCounter < _treeTotal) _treeXML = TreeController.instance.treeControllerInfo.xml.tree[_treeCounter];
			else return; // Кончились деревья на постройку...
			
			reset();
			start();
		}
		
		// Delete но не dispose()!
		private function deleteCreateTreeErrorController():void {
			_createTreeErrorController.removeEventListener(CreateTreeErrorController.ERROR_EVENT, onError);
			_createTreeErrorController.removeEventListener(CreateTreeErrorController.SUCCESS_EVENT, onSuccess);
			_createTreeErrorController = null;
		}
	}
}

class __ {
	
}