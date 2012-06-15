package family.tree {
	
	import family.desktop.Desktop;
	import family.level.LevelCell;
	import family.tree.control.TreeController;
	
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	
	public class TreeBorder extends Sprite implements IUpdate,IDisposable {
		
		private static const ACTIVE_BORDER_COLOR:Number = 0xFF0000;
		private static const BORDER_COLOR:Number = 0x000000;
		
		private static const BORDER_ALPHA:Number = .2;
		private static const BORDER_THIKNESS:Number = 1;
		private static const BORDER_ROUND:uint = 15;
		
		private var _tree:Tree;
		private var _rect:Rectangle;
		private var _allTreeLevelCells:Array = []; // Все клетки дерева, занятые по его периметру (информация, постоянно обновляемая при auto-режиме)
		
		public function TreeBorder(tree:Tree) {
			_tree = tree;
		}
		
		public function get rect():Rectangle { return _rect; }
		
		public function get allTreeLevelCells():Array { return _allTreeLevelCells; }
		
		public function reset():void {
			for (var i:uint = 0; i < _allTreeLevelCells.length; i++) LevelCell(_allTreeLevelCells[i]).unLight();
		}
		
		/** Интерфейс */
		
		/** Определяем пределы дерева */
		public function update():void {
			graphics.clear();
			
			_rect = _tree.getRect(_tree);
			
			var color:Number;
			if (_tree.active) color = ACTIVE_BORDER_COLOR;
			else color = BORDER_COLOR;
			
			graphics.lineStyle(BORDER_THIKNESS, color, BORDER_ALPHA);
			graphics.drawRoundRect(rect.x, rect.y, rect.width, rect.height, BORDER_ROUND, BORDER_ROUND);
			graphics.endFill();
			
			/** Если режим auto, то при каждом обновлении границ дерева - обновляем все клетки, принадлежащие этому дереву по его границе BoundingBox */
			reset();
			_allTreeLevelCells = Desktop.instance.getAllTreeLevelCells(this);
			for (var i:uint = 0; i < _allTreeLevelCells.length; i++) LevelCell(_allTreeLevelCells[i]).lightBusy();
		}
		
		public function dispose():void {
			reset();
		}
	}
}