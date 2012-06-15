package layers {
	
	import flash.display.Sprite;
	
	import utils.Utils;
	
	public class BackgroundLayer extends Sprite implements IUse,IDisposable {
		
		private var _back:Back = new Back();
		
		public function BackgroundLayer() {
			
		}
		
		/** Интерфейс */
		
		public function init():void {
			addChild(_back);
		}
		
		public function update():void {
			_back.x = -Utils.stageWidthHalf;
			_back.y = -Utils.stageHeightHalf;
			_back.width = Utils.stageWidth;
			_back.height = Utils.stageHeight;
		}
		
		public function dispose():void {
			
		}
	}
}