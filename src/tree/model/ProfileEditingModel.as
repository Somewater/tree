package tree.model {
	public class ProfileEditingModel {

		public var editEnabled:Boolean = false;
		public var edited:Person;
		public var joinType:JoinType;
		public var from:Person;

		public function ProfileEditingModel() {
		}

		public function clear():void{
			edited = null;
			joinType = null;
			from = null;
			editEnabled = false;
		}
	}
}
