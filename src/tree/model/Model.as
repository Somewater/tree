package tree.model {
	import tree.common.Bus;
	import tree.model.base.ModelCollection;

	public class Model {

		public var trees:TreesCollection;
		public var persons:PersonsCollection;
		public var nodes:NodesCollection;

		public function Model(bus:Bus) {
			trees = new TreesCollection(bus);
			persons = new PersonsCollection(bus);
			nodes = new NodesCollection(persons, bus);
		}

		/**
		 * Кто запустил приложение
		 * @return
		 */
		public function get user():Person {
			return null;
		}

		/**
		 * Относительно кого строится дерево
		 */
		public function get owner():Person {
			return persons.get(trees.first.uid.toString());
		}
	}
}
