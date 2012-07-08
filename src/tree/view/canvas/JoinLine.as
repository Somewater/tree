package tree.view.canvas {
	import flash.display.Sprite;

	import tree.model.Join;
	import tree.model.Node;

	public class JoinLine extends LineBase{

		private var _data:Join;
		private var drawed:Boolean = false;

		public function JoinLine() {
		}


		public function get data():Join {
			return _data;
		}

		public function set data(value:Join):void {
			_data = value;
			_data.associate.node.positionChanged.add(refreshPosition);
			_data.from.node.positionChanged.add(refreshPosition);
			refreshData();
			refreshPosition(null);
		}

		private function refreshData():void {

		}

		private function refreshPosition(node:Node):void {
		}
	}
}
