package tree.model {
	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;

	import tree.common.Bus;
	import tree.common.Config;
	import tree.model.base.ModelCollection;

	public class GenerationsCollection extends ModelCollection{

		private var persons:PersonsCollection;
		private var bus:Bus;
		private var matrixes:MatrixCollection;

		public var generationChanged:ISignal;

		public function GenerationsCollection(persons:PersonsCollection, bus:Bus, matrixes:MatrixCollection) {
			this.persons = persons;
			this.bus = bus;
			this.matrixes = matrixes;

			generationChanged = new Signal(Generation);
		}

		public function get(generation:int):Generation {
			var g:Generation = hash[generation + ''];
			if(!g) {
				g = new Generation(this, generation, persons, bus, matrixes);
				g.changed.add(onGenerationChanged);
				add(g);
			}
			return g;
		}

		private function onGenerationChanged(g:Generation):void {
			generationChanged.dispatch(g);
		}
	}
}
