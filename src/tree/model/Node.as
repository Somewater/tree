package tree.model {
	import org.osflash.signals.ISignal;

	import tree.model.base.ICollection;

	import tree.model.base.IModel;
	import tree.model.base.ModelCollection;

	/**
	 * Отвечает за геометрическое расположение
	 * Является коллекцией join-ов которые уже были построены
	 */
	public class Node extends JoinCollectionBase implements IModel, ICollection{

		public var person:Person;
		public var uid:int;

		public var x:Number = 0;
		public var y:Number = 0;

		public var dist:int = 0;// кратчайшее расстояние до центра дерева
		public var vector:int = 0;// растёт для последующего потомства
		public var vectCount:int = 0;
		public var generation:int = 0;

		public function Node(person:Person) {
			super();

			this.useJoinsCache = false;
			this.person = person;
			this.uid = person.uid;
		}

		override public function get id():String {
			return person ? person.id : null;
		}

		public function get level():int {
			return vector * vectCount;
		}
	}
}
