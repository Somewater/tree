package tree.model {
	import org.osflash.signals.ISignal;

	import tree.model.base.ICollection;
	import tree.model.base.IModel;
	import tree.model.base.ModelCollection;

	/**
	 * Модель человека. Одновременно, является коллекцией join
	 */
	public class Person extends JoinCollectionBase implements IModel, ICollection{

		public var name:String;
		public var male:Boolean;

		private var nodes:NodesCollection;
		public var photo:String;

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
	}
}
