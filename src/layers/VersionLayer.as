package layers {
	
	import flash.display.Sprite;
	import flash.geom.Point;
	
	import utils.Utils;
	
	public class VersionLayer extends Sprite implements IUse,IDisposable {
		
		private static const VERSION_SHIFT:Point = new Point(30, 10);
		
		private var _version:Version;
		
		public function VersionLayer() {
			
		}
		
		/** Интерфейс */
		
		public function init():void {
			_version = new Version(ConsecutiveFamilyTree.VERSION);
			addChild(_version);
		}
		
		public function update():void {
			x = Utils.stageWidthHalf - width - VERSION_SHIFT.x;
			y = Utils.stageHeightHalf - height - VERSION_SHIFT.y;
		}
		
		public function dispose():void {
			
		}
	}
}