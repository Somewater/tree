package tree.model.lines {
	import tree.model.Join;

	public class Line {

		public var start:int;
		public var end:int;
		public var constant:int;

		public var horizontal:Boolean;
		public var join:Join;

		public var from:uint;
		public var to:uint;

		public function Line() {
		}
	}
}
