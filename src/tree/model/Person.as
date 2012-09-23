package tree.model {
	import org.osflash.signals.ISignal;

	import tree.model.base.ICollection;
	import tree.model.base.IModel;
	import tree.model.base.ModelCollection;

	/**
	 * Модель человека. Одновременно, является коллекцией join
	 */
	public class Person extends JoinCollectionBase implements IModel, ICollection{

		public var male:Boolean;

		private var nodes:NodesCollection;
		public var photo:String;

		public var tree:TreeModel;

		public var firstName:String;
		public var lastName:String;
		public var middleName:String;
		public var maidenName:String;
		public var birthday:Date = new Date();
		public var deathday:Date;
		public var email:String;
		public var post:String;
		public var profileUrl:String;

		public function Person(nodes:NodesCollection) {
			this.nodes = nodes;
		}

		override public function get id():String {
			return uid + '';
		}

		public function get female():Boolean{return !male;}

		public function toString():String {
			return '[' + this.name + ' ' + uid + ']';
		}

		public function get node():Node {
			return nodes.get(this.uid + '');
		}

		public function dirtyMattyCache():void {
			_marryCalculated = false;
		}

		public function get name():String {
			return lastName + ' ' + firstName;
		}

		public function get fullname():String {
			return lastName + ' ' + firstName + ' ' + middleName;
		}

		public function get died():Boolean{
			return deathday != null;
		}

		public function get readonly():Boolean{
			return false;
		}

		public function get visible():Boolean {
			return node && node.visible;
		}
	}
}
