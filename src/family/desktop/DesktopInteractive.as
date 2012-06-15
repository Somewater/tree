package family.desktop {
	
	import family.level.Level;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.Point;
	
	import utils.Utils;
	
	public class DesktopInteractive extends Sprite implements IUpdate {
		
		private static const SHIFT:uint = 7;
		
		private static var _desktopInteractive:DesktopInteractive;
		
		public function DesktopInteractive(lock:__) {
			_desktopInteractive = this;
		}
		
		public static function get instance():DesktopInteractive {
			if (_desktopInteractive == null) _desktopInteractive = new DesktopInteractive(new __());
			return _desktopInteractive;
		}
				
		/** Интерфейс */
		
		public function init():void {
			
		}
		
		public function update():void {
			while(numChildren) removeChildAt(0);
		
			var level:Level;
			var k:int;
			var levels:Array = Desktop.instance.levels;
			
			for (var i:uint = 0; i < levels.length; i++) {
				level = levels[i];
				k = level.k;
				
				if (k > -1) { // Ряды в уровне есть...
					level.minus.y = level.y + SHIFT;
					addChild(level.minus);
					
					if (k < Desktop.instance.desktopInfo.levelRowMaxNum) { // Покамест меньше рядов, чем можно поставить...
						level.plus.y = level.y + level.height - level.plus.height - SHIFT;
						addChild(level.plus);
					}					
				} else { // Рядов нет...
					level.plus.y = level.y;
					addChild(level.plus);
				}
			}			
		}
		
		public function dispose():void {
			
		}
	}
}

class __ {
	
}