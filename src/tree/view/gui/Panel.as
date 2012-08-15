package tree.view.gui {
	import flash.display.Sprite;

	public class Panel extends Sprite{
		public function Panel() {
		}

		public function setSize(w:int, h:int):void {
			graphics.clear();
			graphics.beginFill(0xEEEEEE);
			graphics.drawRect(0, 0, w, h);
		}
	}
}
