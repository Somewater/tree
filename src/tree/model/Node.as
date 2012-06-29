package tree.model {
	import org.osflash.signals.ISignal;

	import tree.model.base.IModel;

	/**
	 * Отвечает за геометрическое расположение
	 */
	public class Node extends ModelBase implements IModel{

		public var person:Person;
		public var uid:int;

		public var x:int = 0;
		public var y:int = 0;

		public var d:int = 0;// кратчайшее расстояние до центра дерева
		public var v:int = 0;// растёт для последующего потомства
		public var vc:int = 0;
		public var l:int = 0;

		public function Node(person:Person) {
			this.person = person;
			this.uid = person.uid;
		}

		override public function get id():String {
			return person ? person.id : null;
		}
	}
}
