package tree.model {
	import flash.geom.Point;

	import tree.Tree;

	import tree.common.Bus;
	import tree.model.base.ModelCollection;

	public class Model {

		public var trees:TreesCollection;
		public var persons:PersonsCollection;
		public var nodes:NodesCollection;
		public var generations:GenerationsCollection;
		public var matrixes:MatrixCollection;
		private var _zoom:Number = 1;
		private var _mousePosition:Point = new Point();

		//////////////////////////
		//                      //
		//      view data       //
		//                      //
		//////////////////////////
		/**
		 * Очередь на прорисовку, array of join
		 */
		public var joinsForDraw:Array = [];
		public var joinsForRemove:Array = [];

		public var joinsQueue:Array = [];

		/**
		 * соединения, которые уже были нарисованы
		 */
		public var drawedNodesUids:Array = [];

		private var bus:Bus;

		public function Model(bus:Bus) {
			this.bus = bus;
			trees = new TreesCollection(bus);
			persons = new PersonsCollection(bus);
			nodes = new NodesCollection(persons, bus);
			matrixes = new MatrixCollection();
			generations = new GenerationsCollection(persons, bus, matrixes);
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

		public function get zoom():Number {
			return _zoom;
		}

		public function set zoom(value:Number):void {
			if(value != _zoom) {
				_zoom = value;
				bus.zoom.dispatch(value);
			}
		}

		public function get mousePosition():Point {
			_mousePosition.x = Tree.instance.mouseX;
			_mousePosition.y = Tree.instance.mouseY;
			return _mousePosition;
		}
	}
}
