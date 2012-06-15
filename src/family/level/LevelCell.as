package family.level {
	
	import family.desktop.Desktop;
	import family.item.TreeItem;
	
	import flash.display.Shape;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	
	public class LevelCell extends Shape implements IUse,ILight,IDisposable {
		
		private static const LIGHT_COLOR:Number = 0xFF0000;
		private static const LIGHT_ALPHA:Number = .1;
		
		private static const LIGHT_BUSY_COLOR:Number = 0xFFFFFF;
		private static const LIGHT_BUSY_ALPHA:Number = .3;
		
		private var _level:Level;
		private var _pos:Point;
		
		private var _levelGrid:Point;
		private var _fill:Vector3D;
		private var _outline:Vector3D;
		private var _halfSize:Number;
		
		private var _treeItem:TreeItem; // TreeItem, который в данный момент находится в этой ячейке...
		
		public function LevelCell(level:Level, pos:Point) {
			_level = level;
			_pos = pos;
			_fill = _level.desktop.desktopInfo.levelCellInfo.fill;
			_outline = _level.desktop.desktopInfo.levelCellInfo.outline;
			_levelGrid = _level.desktop.desktopInfo.levelGrid;
			_halfSize = _level.desktop.desktopInfo.halfSize;
		}
		
		public function get level():Level { return _level; }
		public function get pos():Point { return _pos; }
		
		public function get treeItem():TreeItem { return _treeItem; }
		public function set treeItem(value:TreeItem):void { _treeItem = value; }
		
		private function draw(color:Number, alpha:Number):void {
			graphics.clear();
			graphics.beginFill(color, alpha);
			graphics.lineStyle(_outline.x, _outline.y, _outline.z);
			graphics.drawRoundRect(0, 0, _levelGrid.x, _levelGrid.y, _fill.x, _fill.x);
			graphics.endFill();
		}
		
		public function lightBusy():void {
			draw(LIGHT_BUSY_COLOR, LIGHT_BUSY_ALPHA);
		}
		
		/** Интерфейс */
		
		public function init():void {
			update();
		}
		
		public function update():void {
			draw(_fill.y, _fill.z);
		}
		
		public function light():void {
			draw(LIGHT_COLOR, LIGHT_ALPHA);
		}
		
		public function unLight():void {
			update();
		}
		
		public function dispose():void {
			
		}
	}
}