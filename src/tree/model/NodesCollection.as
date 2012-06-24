package tree.model {
	import org.osflash.signals.ISignal;

	import tree.common.Bus;
	import tree.model.TreesCollection;

	import tree.model.base.ModelCollection;

	public class NodesCollection extends ModelCollection{
		private var persons:PersonsCollection;
		private var bus:Bus;

		public function NodesCollection(persons:PersonsCollection, bus:Bus) {
			this.persons = persons;
			this.bus = bus;
		}

		public function get(id:String):Node
		{
			return this.hash[id];
		}

		public function allocate(person:Person):Node {
			return new Node(person);
		}
	}
}
