package tree.signal {
	import flash.geom.Point;

	public class DragSignal {

		public var startPoint:Point = new Point();
		public var currentPoint:Point = new Point();
		public var lastPoint:Point = new Point();
		public var totalDelta:Point = new Point();
		public var delta:Point = new Point();

		public function DragSignal() {
		}
	}
}
