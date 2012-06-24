package tree.signal {
	public class RequestSignal {

		public static const SIGNAL:String = 'request';

		public static const USER_TREE:String = 'userTree';

		public var type:String

		public function RequestSignal(type:String) {
			this.type = type;
		}
	}
}
