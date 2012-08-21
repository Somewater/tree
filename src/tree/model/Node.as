package tree.model {
	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;

	import tree.model.base.ICollection;

	import tree.model.base.IModel;
	import tree.model.base.ModelCollection;

	/**
	 * Отвечает за геометрическое расположение
	 * Является коллекцией join-ов которые уже были построены
	 */
	public class Node extends JoinCollectionBase implements IModel, ICollection{

		public static var EMPTY_ROLL:Array = [];

		public var person:Person;
		public var join:Join;

		public var x:Number = 0;
		public var y:Number = 0;

		public var dist:int = 0;// кратчайшее расстояние до центра дерева
		public var vector:int = 0;// растёт для последующего потомства
		public var vectCount:int = 0;
		public var generation:int = 0;

		public var visible:Boolean = false;

		public var positionChanged:ISignal;
		public var rollChanged:ISignal;

		/**
		 * Массив Node-в, сворачиваемых-разворачиваемых текущей
		 */
		public var slaves:Array;
		public var lords:Array;
		public var slavesUnrolled:Boolean = true;// "рабы" развернуты


		public function Node(person:Person) {
			super();

			this.useJoinsCache = false;
			this.person = person;
			this.uid = person.uid;

			positionChanged = new Signal(Node);
			rollChanged = new Signal(Node);
		}

		override public function get id():String {
			return person ? person.id : null;
		}

		public function get level():int {
			return vector * vectCount;
		}

		public function firePositionChange():void {
			positionChanged.dispatch(this);
		}

		public function fireRollChange():void{
			rollChanged.dispatch(this);
		}

		public function get name():String {
			return person ? person.name : null;
		}

		public function toString():String {
			return '[' + this.name + ' #' + uid + ']';
		}

		/**
		 * Должна быть показана, т.к. все ее "лорды" значатся как развернутые
		 */
		public function get unrolled():Boolean{
			for each(var n:Node in lords)
				if(!n.slavesUnrolled)
					return false;
			return true;
		}
	}
}
