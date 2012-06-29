package tree.view.canvas {
	import flash.display.Sprite;

	import tree.model.Node;

	public class NodeIcon extends Sprite{

		public static const WIDTH:int = 90;
		public static const HEIGHT:int = 125;

		protected var _data:Node;

		public function NodeIcon() {
		}

		public function set data(value:Node):void {
			this._data = value;
			refresh();
		}

		protected function refresh():void {

		}
	}
}
