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
		public var oddX:Boolean = true;
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
			return (vector * vectCount) * 2 + (oddX ? 0 : 1);
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

		/**
		 * Есть "рабы" и "лорды" его рабов также входят в число его "рабов"
		 */
		public function isLord():Boolean{
			if(!slaves || slaves.length == 0) return false;
			var slavesHash:Array = [];
			var lordsHash:Array = [];
			var n:Node;
			for each(n in slaves)
				slavesHash[n.uid] = true;
			for each(n in lords)
				lordsHash[n.uid] = true;
			for each(n in slaves)
				for each(var lord2:Node in n.lords)
					if(lord2 != this && !slavesHash[lord2.uid] && !lordsHash[lord2.uid])
						return false;// это не единоличный "лорд" "раба" n
			return true;
		}
	}
}
