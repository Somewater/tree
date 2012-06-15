package layers {
	
	import flash.display.Sprite;
	
	import menu.Menu;
	
	import utils.Utils;
	
	public class MenuLayer extends Sprite implements IUse,IDisposable {
		
		private static const SHIFT:uint = 20;
		
		public var menuInstance:Menu;
		
		public function MenuLayer() {
			
		}
		
		/** Интерфейс */
		
		public function init():void {
			menuInstance = new Menu();
			menuInstance.init();
			addChild(menuInstance);
		}
		
		public function update():void {
			x = -Utils.stageWidthHalf + SHIFT;
			y = Utils.stageHeightHalf - menuInstance.height - SHIFT;
		}
		
		public function dispose():void {
			
		}
	}
}