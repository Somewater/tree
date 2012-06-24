package tree.model {
	import tree.model.base.ICollection;
	import tree.model.base.IModel;
	import tree.model.base.ModelCollection;

	/**
	 * Модель дерева. Одновременно, является коллекцией Person
	 */
	public class TreeModel extends ModelCollection implements IModel, ICollection{

		public var uid:int;
		public var level:int;

		public var persons:PersonsCollection;

		public function TreeModel() {
		}

		public function get id():String {
			return uid + "";
		}
	}
}
