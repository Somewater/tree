package tree.model {
	import org.osflash.signals.ISignal;

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

		public function allocate(nodes:NodesCollection):Person {
			return new Person(nodes);
		}
	}
}
