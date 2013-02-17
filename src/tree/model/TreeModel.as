package tree.model {
	import tree.common.Bus;
	import tree.common.IClear;
	import tree.model.base.ICollection;
	import tree.model.base.IModel;
	import tree.model.base.ModelCollection;

	/**
	 * Модель дерева. Одновременно, является коллекцией Person
	 */
	public class TreeModel extends ModelBase implements IClear{

		public var uid:int;
		public var level:int;
		public var name:String;

		public var persons:PersonsCollection;
		public var nodes:NodesCollection;

		public var visible:Boolean = false;// дерево уже построено (в процессе построения)
		public var number:int = 0;

		public var minX:int = 0;
		public var maxX:int = 0;

		public var shiftX:int = 0;
		public var dirty:Boolean;// одна из нод изменила размеры дерева
		public var left:Boolean = true;// поддерево располагается слева или справа от главного



		public function TreeModel(bus:Bus) {
			persons = new PersonsCollection(bus);
			nodes = new NodesCollection(persons, bus);
		}

		override public function get id():String {
			return uid + "";
		}

		public function get owner():Person {
			return persons.get(uid + '');
		}

		public function clear():void{

		}

		public function root():Boolean{
			return number == 0;// корневое поддерево (его корнем является owner просматриваемых поддеревьев)
		}
	}
}
