package tree.model.lines {
	import tree.model.Join;

	internal class Line {

		public var start:int;
		public var end:int;
		public var constant:int;

		public var horizontal:Boolean;
		public var join:Join;

		public function Line() {
		}
	}
}
