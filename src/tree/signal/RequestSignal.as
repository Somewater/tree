package tree.signal {
import org.osflash.signals.ISignal;
import org.osflash.signals.Signal;

import tree.common.IClear;
import tree.model.Join;
import tree.model.JoinType;
import tree.model.Person;

	public class RequestSignal implements IClear{

		public static const SIGNAL:String = 'request';

		public static const USER_TREE:String = 'userTree';

		public static const DELETE_USER:String = 'deleteUser';

		public static const ADD_USER:String = 'addUser';

		public static const EDIT_USER:String = 'editUser';

		public static const ADD_RELATION:String = 'addRelation';

		public static const SAVE_TREE:String = 'saveTree';

		public var type:String

		public var uid:int;

		public var person:Person;

		public var joinFrom:Person;
		public var joinType:JoinType;

		public var onSucces:ISignal = new Signal(ResponseSignal);// callback(response:ResponseSignal)
		public var onError:ISignal = new Signal(ResponseSignal);// callback(response:ResponseSignal)
		public var onComplete:ISignal = new Signal(ResponseSignal);// callback(response:ResponseSignal)  // произошло завершение запроса, неважно, успешное или неудачное
		public var silent:Boolean = false;

		public function RequestSignal(type:String) {
			this.type = type;
		}

		public function clear():void {
			onSucces.removeAll();
			onError.removeAll();
			onComplete.removeAll();
		}
	}
}
