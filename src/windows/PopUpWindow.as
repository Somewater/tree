package windows {
	
	import flash.display.Sprite;
	import flash.events.Event;
	
	import layers.control.LayerController;
	
	import utils.Utils;
	
	import windows.Window;
	
	public class PopUpWindow extends Sprite implements IUpdate {
		
		private static const COLOR:Number = 0xFFFFFF;
		private static const ALPHA:Number = .3;
		
		private static var _popUp:PopUpWindow;
		
		private var _window:Window;
		
		public function PopUpWindow(lock:__) {
			_popUp = this;
		}
		
		public static function get instance():PopUpWindow {
			if (_popUp == null) new PopUpWindow(new __());
			return _popUp;
		}
		
		public function show(window:Window):void {
			LayerController.instance.addPopUp(_popUp);
			_window = window;
			window.removeListeners();
			addChild(_window);
			update();
		}
		
		private function close(e:Event):void {
			_window.removeEventListener(Window.CLOSE_WINDOW_EVENT, close);
			LayerController.instance.clearPopUp();
			_window = null;
		}
		
		/** Интерфейс */
		
		public function update():void {
			if (_window) {
				graphics.clear();
				graphics.beginFill(COLOR, ALPHA);
				graphics.drawRect(-Utils.stageWidthHalf, -Utils.stageHeightHalf, Utils.stageWidth, Utils.stageHeight);
				graphics.endFill();
				_window.addEventListener(Window.CLOSE_WINDOW_EVENT, close);
				_window.x = -_window.width * .5;
				_window.y = -_window.height * .5;
			}			
		}
	}
}

class __ {
	
}