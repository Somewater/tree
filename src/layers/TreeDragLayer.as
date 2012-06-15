package layers {
	
	import flash.display.Sprite;
	
	import utils.Utils;
	
	public class TreeDragLayer extends Sprite implements IUse,IDisposable {
		
		public function TreeDragLayer() {
			
		}
		
		/** Интерфейс */
		
		public function init():void {
			update();
		}
		
		public function update():void {
			graphics.clear();
			graphics.beginFill(0, 0);
			graphics.drawRect(0, 0, Utils.stageWidth, Utils.stageHeight);
			graphics.endFill();
			x = -Utils.stageWidthHalf;
			y = -Utils.stageHeightHalf;
		}
		
		public function dispose():void {
			
		}
	}
}