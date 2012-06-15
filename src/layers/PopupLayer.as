package layers {
	
	import flash.display.Sprite;
	
	import windows.PopUpWindow;
	
	public class PopupLayer extends Sprite implements IUse,IDisposable {
		
		public function PopupLayer() {
			
		}
		
		/** Интерфейс */
		
		public function init():void {
			
		}
		
		public function update():void {
			PopUpWindow.instance.update();
		}
		
		public function dispose():void {
			
		}
	}
}