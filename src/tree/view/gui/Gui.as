package tree.view.gui {
	import flash.display.Sprite;

	import org.osflash.signals.ISignal;

	import tree.common.Bus;

	public class Gui extends Sprite{

		private var bus:Bus;

		public function Gui(bus:Bus) {
		}

		public function setSize(w:int, h:int):void {
			graphics.beginFill(0xE0EEB1);
			graphics.drawRect(0, 0, w, h);
		}
	}
}
