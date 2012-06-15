package family.level {
	
	import family.desktop.Desktop;
	import family.Automat;
	import family.tree.control.TreeController;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	public class Level extends Sprite implements IUse,ILight,IDisposable {
		
		public static const REMOVE_LEVEL_ROW_EVENT:String = "RemoveRowEvent";
		
		private static const NO_LEVEL_DEFAULT_HEIGHT:uint = 15;
		
		private static const LIGHT_COLOR:Number = 0xFF0000;
		private static const LIGHT_ALPHA:Number = .1;
		
		private var _desktop:Desktop;
		
		private var _uid:uint;
		
		private var _k:int = -1;
		
		private var _color:Number;
		private var _alpha:Number;
		
		private var _cells:Array = []; // Матрица ячеек
		
		private var _minus:MovieClip = new MinusLevelRow;
		private var _plus:MovieClip = new PlusLevelRow;
				
		public function Level(
			desktop:Desktop,
			uid:uint
		) {
			_desktop = desktop;
			_uid = uid;
		}
		
		public function get k():int { return _k; }
		public function set k(value:int):void { _k = value; }
		
		public function get uid():uint { return _uid; }		
		public function get desktop():Desktop { return _desktop; }
		
		public function get minus():MovieClip { return _minus; }
		public function get plus():MovieClip { return _plus; }
		
		/** Получить ячейку по её CellPos */
		public function getLevelCellByCellPos(cellPos:Point):LevelCell {
			if (cellPos.x < 0 || cellPos.y < 0 || cellPos.x > _cells.length - 1 || cellPos.y > _desktop.desktopInfo.levelCellNums - 1) return null;
			return _cells[cellPos.x][cellPos.y];
		}
		
		/** Получить примерную ячейку по реальным координатам */
		public function getLevelCellPosByPos(pos:Point):Point {
			var xPos:uint = int((pos.x + _desktop.desktopInfo.halfSize) / _desktop.desktopInfo.maxTreeItemHShift);
			var yPos:uint = int((pos.y - y) / _desktop.desktopInfo.maxTreeItemVShift);
			return new Point(yPos, xPos);
		}
		
		/** Пустые ли все ряды данного уровня, чтобы его можно было закрыть */
		public function isEmpty():Boolean {
			var levelCell:LevelCell;
			for (var i:uint = 0; i < _cells.length; i++) {
				if (_cells[i] != null) {
					for (var j:uint = 0; j < _cells[i].length; j++) {
						levelCell = _cells[i][j];
						if (levelCell.treeItem) return false;
					}
				}
			}
			return true;
		}
		
		/** Получить центральную клетку определенного ряда */
		public function getCenterLevelCellByRow(row:uint):LevelCell {
			if (_cells[row] != null) {
				var num:uint = Math.ceil(_cells[row].length / 2);
				return _cells[row][num];
			}
			return null;
		}
		
		/** Получить все клетки во всех рядах от fromYPos до toYPos по примерным реальным координатам fromPoint toPoint */
		public function getDYCells(from:uint, to:uint):Array {
			var arr:Array = [];
			if (k == -1) return arr;
			for (var i:uint = 0; i < _cells.length; i++) {
				if (_cells[i]) {
					for (var j:uint = from; j < to; j++) {
						if (_cells[i][j]) arr.push(_cells[i][j]);
					}
				}
			}
			return arr;
		}
		
		/** Получить самые близкие пустые клетки, относительно исходной клетки в конкретном ряду */
		public function getEmptyCellNearCell(row:uint, cells:Array):Array {
			var arr:Array = [];
			
			var beginIndex:int = -1;
			
			// Определяем самого левого PresentPartner, относительно которого будут строиться следующие за ним TreeItem...
			if (cells.length > 1) { // Значит есть Union
				if (cells[0].y < cells[1].y) beginIndex = 0;
				else beginIndex = 1;
			} else {
				beginIndex = 0;
			}
			
			var beginPos:Point = cells[beginIndex];
			
			var targetRow:Array = _cells[row];
			var levelCell:LevelCell;
			
			var i:int;
			
			function isFrontCellsEmpty(pos:Point):Boolean { // Пустые ли клетки по краям...
				var l:LevelCell = targetRow[pos.y - 1];
				var r:LevelCell = targetRow[pos.y + 1];
				if (l == null || r == null) return false;
				if (l.treeItem || r.treeItem) return false;
				return true;
			}
			
			var p:Point;
			var isFront:Boolean;
			
			var p_:Point;
			var isFront_:Boolean;
			
			var p__:Point;
			var isFront__:Boolean;
			
			// Попробуем сначала в правую сторону...
			// Если ничего не найдем, то попробуем в левую сторону...
			
			function check(levelCell:LevelCell):Array {
				var a:Array = [];
				if (!levelCell.treeItem) { // Пустая ячейка...
					p = levelCell.pos.clone();
					isFront = isFrontCellsEmpty(p);
					if (isFront) { // Свободные края...
						if (cells.length > 1) { // Значит есть Union
							// Проверяем, через одну клетку свободны ли края для второго TreeItem...
							p_ = new Point(p.x, p.y + 1);
							isFront_ = isFrontCellsEmpty(p_);
							
							p__ = new Point(p.x, p.y + 2);
							isFront__ = isFrontCellsEmpty(p__);
							
							if (isFront_ && isFront__) {
								a.push(targetRow[p.y]);
								a.push(targetRow[p__.y]);
								return a;
							}							
						} else {
							a.push(targetRow[p.y]);
							return a;
						}						
					}
				}
				return null;
			}
			
			var res:Array;
			var toRight:Array;
			var toLeft:Array;
			
			// Влево...
			for (i = beginPos.y; i >= 0; i--) {
				res = check(targetRow[i]);
				if (res) {
					toLeft = res;
					arr[Automat.TO_LEFT] = toLeft;
					break;
				}
			}
			
			// Вправо...
			for (i = beginPos.y; i < targetRow.length; i++) {
				res = check(targetRow[i]);
				if (res) {
					toRight = res;
					arr[Automat.TO_RIGHT] = toLeft;
					break;
				}
			}
			
			if (!arr.length) arr = null;
			return arr;
		}
		
		// TreeController дал разрешение на удаление ряда в уровне...
		// Все TreeItems нашли свои свободные ячейки и помещены в них... 
		public function canRemoveRow():void {
			k--;
			removeRow();
			drawBackground();
		}
		
		private function onMinusClick(e:MouseEvent):void {
			if (k > -1) {
				dispatchEvent(new Event(REMOVE_LEVEL_ROW_EVENT)); // Сначала узнаем можно ли сдвинуть TreeItem выше, сдвинем их и только затем удалим ряд...
			}
		}
		
		public function onPlusClick(e:MouseEvent):void {
			if (k < _desktop.desktopInfo.levelRowMaxNum) { // Покамест меньше рядов, чем можно поставить...
				k++;
				
				addRow(k);
				drawBackground();
				
				TreeController.instance.update();
			}
		}
		
		// Закрыть все уровни...
		public function clear():void {
			while(k > -1) canRemoveRow();
		}
		
		private function addRow(row:uint):void {
			var levelCell:LevelCell;
			var preX:uint;
			if (_cells[row] == null) _cells[row] = [];
			for (var j:uint = 0; j < _desktop.desktopInfo.levelCellNums; j++) {
				levelCell = new LevelCell(this, new Point(row, j));
				levelCell.init();
				_cells[row][j] = levelCell;
				
				levelCell.x = _desktop.desktopInfo.maxTreeItemHShift * j - _desktop.desktopInfo.halfSize;
				levelCell.y = _desktop.desktopInfo.levelGrid.y * row + (desktop.desktopInfo.levelRowShift * (row + 1));
				
				addChild(levelCell);
				
				preX = levelCell.x;
			}
		}
		
		private function removeRow():void {
			var levelCell:LevelCell;
			var cellRow:Array = _cells[k + 1];
			for (var j:uint = 0; j < cellRow.length; j++) {
				levelCell = cellRow[j];
				removeChild(levelCell);
				levelCell.dispose();
			}
			_cells.splice(k + 1, 1);
		}
		
		private function drawBackground():void {
			draw(_color, _alpha);
		}
		
		private function draw(color:Number, alpha:Number):void {
			graphics.clear();
			
			graphics.beginFill(color, alpha);
			
			var drawK:uint = _k + 1; // Храним _k как чистое количество рядов, а drawK должен быть больше на 1
			
			if (_k > -1) { // Если уровней больше чем 0, то открываем их полноценно...
				graphics.drawRect(
					-_desktop.desktopInfo.halfSize,
					0,
					_desktop.desktopInfo.size.x,
					(_desktop.desktopInfo.size.y * drawK) + (_desktop.desktopInfo.levelRowShift * (drawK + 1))
				);
				graphics.endFill();
			} else { // Просто показываем небольшую полоску уровня, чтобы можно было с ним взаимодействовать...
				graphics.drawRect(-_desktop.desktopInfo.halfSize, 0, _desktop.desktopInfo.size.x, NO_LEVEL_DEFAULT_HEIGHT);
			}
			
			graphics.endFill();
		}
		
		/** Интерфейс */
		
		public function init():void {
			var type:uint;
			if (!(_uid % 2)) type = 0; 
			else type = 1;
			
			_color = _desktop.desktopInfo.colors[type];
			_alpha = _desktop.desktopInfo.alphas[type];
			
			_minus.addEventListener(MouseEvent.CLICK, onMinusClick);
			_plus.addEventListener(MouseEvent.CLICK, onPlusClick);
			
			_plus.buttonMode = _minus.buttonMode = true;
			
			if (_k > -1) { // Если уровней больше чем 0, то открываем их полноценно...
				// Рисуем ячейки...
				var levelCell:LevelCell;
				var preX:uint;
				for (var i:uint = 0; i < _k + 1; i++) {
					if (_cells[i] == null) _cells[i] = [];
					addRow(i);
				}
			}
			drawBackground();
		}
		
		public function light():void {
			draw(LIGHT_COLOR, LIGHT_ALPHA);
		}
		
		public function unLight():void {
			draw(_color, _alpha);
		}
		
		public function update():void {
			
		}
		
		public function dispose():void {
			_minus.removeEventListener(MouseEvent.CLICK, onMinusClick);
			_plus.removeEventListener(MouseEvent.CLICK, onPlusClick);
		}
	}
}