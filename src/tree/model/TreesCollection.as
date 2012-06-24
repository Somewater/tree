package tree.model {
	import tree.common.Bus;
	import tree.model.base.ModelCollection;

	public class TreesCollection extends ModelCollection{
		private var bus:Bus;

		public function TreesCollection(bus:Bus) {
			this.bus = bus;
		}

		public function get(id:String):TreeModel
		{
			return this.hash[id];
		}

		public function allocate():TreeModel {
			return new TreeModel();
		}

		public function get first():TreeModel {
			return array[0];
		}
	}
}
