package tree.signal {
	import tree.model.Join;
	import tree.model.Person;

	public class RequestSignal {

		public static const SIGNAL:String = 'request';

		public static const USER_TREE:String = 'userTree';

		public static const DELETE_USER:String = 'deleteUser';

		public static const ADD_USER:String = 'addUser';

		public var type:String

		public var uid:int;

		public var addedJoin:Join;

		public function RequestSignal(type:String) {
			this.type = type;
		}
	}
}
