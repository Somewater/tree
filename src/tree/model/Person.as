package tree.model {
	import org.osflash.signals.ISignal;

	import tree.Tree;

	import tree.model.base.ICollection;
	import tree.model.base.IModel;
	import tree.model.base.ModelCollection;

	/**
	 * Модель человека. Одновременно, является коллекцией join
	 */
	public class Person extends JoinCollectionBase implements IModel, ICollection{

		public var male:Boolean;

		public var photo:String;

		public var tree:TreeModel;

		public var firstName:String = '';
		public var lastName:String = '';
		public var middleName:String = '';
		public var maidenName:String;
		public var birthday:Date = new Date();
		public var deathday:Date;
		public var email:String;
		public var post:String;
		public var profileUrl:String;

		public  var open:Boolean;

		public function Person(tree:TreeModel) {
			this.tree = tree;
		}

		override public function get id():String {
			return uid + '';
		}

		public function get female():Boolean{return !male;}

		public function toString():String {
			return '[' + this.name + ' ' + uid + ' (' + (this.male ? 'male' : 'female') + ')]';
		}

		public function get node():Node {
			var t:TreeModel = this.tree
			return t ? t.nodes.get(this.uid + '') : null;
		}

		public function dirtyMattyCache():void {
			_marryCalculated = false;
		}

		public function get name():String {
			return lastName || firstName ? lastName + ' ' + firstName : uid.toString();
		}

		public function get fullname():String {
			return lastName + ' ' + firstName + ' ' + middleName;
		}

		public function get died():Boolean{
			return deathday != null;
		}

		public function set died(value:Boolean):void{
			deathday = value ? new Date() : null;
		}

		public function get readonly():Boolean{
			return false;
		}

		public function get visible():Boolean {
			return node && node.visible;
		}

		public function get isNew():Boolean{
			return !node
		}
	}
}
