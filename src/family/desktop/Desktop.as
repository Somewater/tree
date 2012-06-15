package family.desktop {
	
	import family.item.TreeItem;
	import family.level.Level;
	import family.level.LevelCell;
	import family.tree.TreeBorder;
	import family.tree.control.TreeController;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	
	import layers.TreeLayer;
	import layers.control.LayerController;
	
	import utils.Utils;
	
	public class Desktop extends Sprite implements IUse {
		
		private static var _desktop:Desktop;
		
		private var _desktopInfo:DesktopInfo;
		private var _nums:uint;
		private var _counter:uint;
		
		/** ВНИМАНИЕ! uid уровней уникальны и положительные - идут с самого верхнего до самого нижнего - с 0 до _up.length + _down.length */
		/** НО СТРОЯТСЯ И ОБНОВЛЯЮТСЯ ОТНОСИТЕЛЬНОГО последнего в _up */
		private var _up:Array = [];
		private var _down:Array = [];
		
		public function Desktop(lock:__) {
			_desktop = this;
		}
		
		public static function get instance():Desktop {
			if (_desktop == null) _desktop = new Desktop(new __());
			return _desktop;
		}
		
		public function get desktopInfo():DesktopInfo { return _desktopInfo; }
		public function set desktopInfo(value:DesktopInfo):void { _desktopInfo = value; }
		
		public function get levels():Array { return _up.concat(_down); }
		
		/** Получить Level по его uid */
		public function getLevelByUID(uid:uint):Level {
			var level:Level;
			level = getLevel(_up, uid);
			if (level == null) level = getLevel(_down, uid);
			return level;
		}
		
		/** Получить уровень TreeItem и его ячейку TreeLevel */
		public function getLevelCellByItem(treeItem:TreeItem):Array {
			var realPos:Point = new Point();
			
			var l:uint = treeItem.level;
			var p:Point = treeItem.pos;
			
			var level:Level = getLevelByUID(l);
			
			return [level, level.getLevelCellByCellPos(p)];
		}
		
		/** Закрыть все пустые уровни */
		public function closeAllEmptyLevels():void {
			var levels:Array = levels;
			var level:Level;
			for (var i:uint = 0; i < levels.length; i++) {
				level = levels[i];
				if (level.isEmpty()) level.clear();
			}
			update();
		}
		
		/** Получить все клетки, принадлежащие дереву по его периметру (BoundingBox) */
		public function getAllTreeLevelCells(treeBorder:TreeBorder):Array {
			var arr:Array = [];
			// Получаем все уровни, клетки которых нужно обработать...
			// По 2 точкам (up, down) боундинг бокса получаем уровни...
			// Потом, по координатам получаем примерные пределы dX позиций клеток...
			// Бежим по dX клеткам и смотрим какие из них столкнулись с деревом и заносим их в массив...
			var upLevel:Level;
			var downLevel:Level;
			
			var uL:Point = treeBorder.rect.topLeft;
			var uR:Point = new Point(uL.x + treeBorder.rect.width, uL.y);
			var dR:Point = treeBorder.rect.bottomRight;
			
			var uLGlobal:Point = treeBorder.localToGlobal(uL);
			var dRGlobal:Point = treeBorder.localToGlobal(dR);
			
			var level:Level;
			
			var i:uint;
			
			for (i = 0; i < levels.length; i++) {
				level = levels[i];
				if (upLevel == null && level.hitTestPoint(uLGlobal.x, uLGlobal.y)) upLevel = level;
				if (upLevel) {
					if (downLevel == null && level.hitTestPoint(dRGlobal.x, dRGlobal.y - desktopInfo.treeItemShift)) downLevel = level;
				}
				if (upLevel && downLevel) break;
			}
			
			if (!upLevel || !downLevel) return []; // Покак так...
			
			var cells:Array = [];
			
			var d:Number = level.y + uL.y;
			
			var from:Point = level.getLevelCellPosByPos(new Point(uL.x, d));
			var to:Point = level.getLevelCellPosByPos(new Point(uR.x, d));
			
			var preArr:Array = [];
			
			for (i = upLevel.uid; i <= downLevel.uid; i++) {
				level = getLevelByUID(i);
				cells = level.getDYCells(from.y, to.y + 1);
				preArr = preArr.concat(cells);
			}
			
			// Когда получили весь блок таких клеток, их нужно проверить на столкновение с боундинг боксом для окончательной точной проверки...
			var levelCell:LevelCell;
			for (i = 0; i < preArr.length; i++) {
				levelCell = preArr[i];
				if (levelCell.hitTestObject(treeBorder)) arr.push(levelCell);
			}
			
			return arr;
		}
		
		/** Раскрыть все уровни на определенное количество рядов */
		/** 0 - 1, 1 - 2 ряда, 2 - 3 ряда */
		public function openAllLevelsForRow(rows:uint):void {
			var level:Level;
			for (var i:uint = 0; i < levels.length; i++) {
				level = levels[i];
				if (level.k == -1) {
					// Добавляем столько же рядов в уровень, какого уровня главный mainTreeItem...
					for (i = 0; i <= rows; i++) level.onPlusClick(null);
				} else if (level.k < rows){
					var dr:uint = level.k - rows;
					for (i = 0; i < dr; i++) level.onPlusClick(null);
				}
			}
			update();
		}
		
		/** Получить CenterLevelCell с учетом, того, что обрабатывается только 1 ряд в уровне */
		public function getCenterLevelCell():LevelCell {
			var centerLevel:Level = _down[0];
			return centerLevel.getCenterLevelCellByRow(0);
		}
		
		/** Получить определенные клетки по спиральному квадрату относительно центра		
		 * ВНИМАНИЕ! Пока только используем этот метод если во всех рядах открыт только 1 ряд*/
		public function getSpiralCellPeriod(centerCell:LevelCell, period:uint):Array {
			var arr:Array = [];
			
			var centerLevel:uint = centerCell.level.uid;
			var centerPos:Point = centerCell.pos;
			
			var from:int = centerPos.y - period;
			var to:uint = centerPos.y + period;
			
			var upLevel:int = centerLevel - period;
			var downLevel:uint = centerLevel + period;

			// Когда уже нет никаких клеток...
			if (from < 0 && to >= desktopInfo.levelCellNums && upLevel < 0 && downLevel >= levels.length) {
				return null;
			}
			
			var i:uint
			
			var cells:Array;
			var level:Level;
			var cell:LevelCell;
			var p:Point;
			
			if (upLevel >= 0) {
				level = getLevelByUID(upLevel);
				cells = level.getDYCells(from, to);
				arr = arr.concat(cells);
			} else {
				upLevel = 0;
			}
			
			if (downLevel < levels.length) {
				level = getLevelByUID(downLevel);
				cells = level.getDYCells(from, to);
				arr = arr.concat(cells);
			} else {
				downLevel < levels.length - 1;
			}
			
			cells = [];
			if (from >= 0) {
				p = new Point(0, from);
				for (i = upLevel; downLevel; i++) {
					level = levels[i];
					cell = level.getLevelCellByCellPos(p);
					cells.push(cell);
				}
			}
			
			cells = [];
			if (to < desktopInfo.levelCellNums) {
				p = new Point(0, to);
				for (i = upLevel; downLevel; i++) {
					level = levels[i];
					cell = level.getLevelCellByCellPos(p);
					cells.push(cell);
				}
			}
			
			return arr;			
		}

		private function createLevels(arr:Array):void {
			var level:Level;
			var l:uint = _nums + _counter;
			for (var i:uint = _counter; i < l; i++) {
				level = new Level(this, i);
				level.k = TreeController.instance.getTreeItemMaxRowPosByLevel(i);
				arr.push(level);
				
				level.addEventListener(Level.REMOVE_LEVEL_ROW_EVENT, onRemoveLevelRow);
				
				level.init();
				_counter++;
			}
		}
		
		private function onRemoveLevelRow(e:Event):void {
			TreeController.instance.tryRemoveLevelRow(Level(e.target));
		}
		
		private function getLevel(arr:Array, uid:uint):Level {
			var level:Level;
			for (var i:uint = 0; i < arr.length; i++) {
				level = Level(arr[i]);
				if (level.uid == uid) return level;
			}
			return null;
		}
		
		/** Интерфейс */
		
		public function init():void {
			_desktopInfo = desktopInfo;
			
			_nums = Math.floor(_desktopInfo.levelNums / 2);
			
			createLevels(_up);
			createLevels(_down);
			
			update();
		}
		
		/** Перестраиваем и обновляем уровни */
		public function update():void {
			var level:Level;
			var preLevel:Level;
			var i:int;
			
			// Up
			for (i = _up.length - 1; i >= 0 ; i--) {
				level = _up[i];
				if (i < _up.length - 1) {
					preLevel = Level(_up[i + 1]);
					level.y = preLevel.y - level.height;
				} else {
					level.y = -level.height;
				}
				addChildAt(level, 0);
			}
			
			// Down
			for (i = 0; i < _down.length; i++) {
				level = _down[i];
				if (i) {
					preLevel = Level(_down[i - 1]);
					level.y = preLevel.y + preLevel.height;
				}				
				addChildAt(level, 0);
			}
			
			DesktopInteractive.instance.update();
		}		
	}
}

class __ {
	
}