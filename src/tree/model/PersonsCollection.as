package tree.model {
	import org.osflash.signals.ISignal;

	import tree.Tree;

	import tree.common.Bus;

	import tree.model.base.ModelCollection;

	public class PersonsCollection extends ModelCollection{

		private var bus:Bus;

		public function PersonsCollection(bus:Bus) {
			this.bus = bus;
		}

		public function get(id:String):Person
		{
			return this.hash[id];
		}

		public function allocate(tree:TreeModel):Person {
			return new Person(tree);
		}
	}
}
