package tree.model {
	import tree.common.Bus;
	import tree.common.Config;
	import tree.model.base.ModelCollection;

	public class GenerationsCollection extends ModelCollection{

		private var persons:PersonsCollection;
		private var bus:Bus;

		public function GenerationsCollection(persons:PersonsCollection, bus:Bus) {
		}

		public function get(generation:int):Generation {
			var g:Generation = hash[generation + ''];
			if(!g) {
				g = new Generation(persons, bus);
				add(g);
			}
			return g;
		}
	}
}
