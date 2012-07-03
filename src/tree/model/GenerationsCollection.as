package tree.model {
	import tree.common.Bus;
	import tree.common.Config;
	import tree.model.base.ModelCollection;

	public class GenerationsCollection extends ModelCollection{

		private var persons:PersonsCollection;
		private var bus:Bus;
		private var matrixes:MatrixCollection;

		public function GenerationsCollection(persons:PersonsCollection, bus:Bus, matrixes:MatrixCollection) {
			this.persons = persons;
			this.bus = bus;
			this.matrixes = matrixes;
		}

		public function get(generation:int):Generation {
			var g:Generation = hash[generation + ''];
			if(!g) {
				g = new Generation(persons, bus, matrixes);
				add(g);
			}
			return g;
		}
	}
}
