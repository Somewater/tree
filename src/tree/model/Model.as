package tree.model {
	import flash.geom.Point;
	import flash.geom.Point;

	import tree.Tree;

	import tree.common.Bus;
	import tree.model.base.ModelCollection;

	public class Model {

		public var trees:TreesCollection;
		public var generations:GenerationsCollection;
		public var matrixes:MatrixCollection;
		private var _zoom:Number = 1;
		public var zoomCenter:Point = new Point();
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
		public var animationTime:Number = 1;// время, отводимое на анимацию появления-скрытия отдельной ноды
		private var _treeViewConstructed:Boolean = false;
		private var _constructionInProcess:Boolean = false;

		public var joinsQueue:Array = [];

		/**
		 * соединения, которые уже были нарисованы
		 */
		public var drawedNodesUids:Array = [];

		public var bus:Bus;

		public static var instance:Model;

		public function Model(bus:Bus) {
			if(instance)
				throw new Error('Must be only one');
			instance = this;
			this.bus = bus;
			trees = new TreesCollection(bus);
			matrixes = new MatrixCollection();
			generations = new GenerationsCollection(bus, matrixes);
		}

		/**
		 * Кто запустил приложение
		 * @return
		 */
		public function get user():Person {
			return null;
		}

		public function get zoom():Number {
			return _zoom;
		}

		public function set zoom(value:Number):void {
			value = Math.max(0.1, Math.min(1, value));
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

		public function clear():void {
			trees.clear();
			generations.clear();
			matrixes.clear();
		}


		public function get treeViewConstructed():Boolean {
			return _treeViewConstructed;
		}

		public function set treeViewConstructed(value:Boolean):void {
			if(_treeViewConstructed != value){
				_treeViewConstructed = value;
				bus.treeViewConstructed.dispatch();
			}
		}


		public function get constructionInProcess():Boolean {
			return _constructionInProcess;
		}

		public function set constructionInProcess(value:Boolean):void {
			if(_constructionInProcess != value){
				_constructionInProcess = value;
				bus.constructionInProcess.dispatch();
			}
		}

		public function get owner():Person {
			return trees.first.owner;
		}

		public function utilize():void{
			joinsForDraw = [];
			joinsForRemove = [];
			_treeViewConstructed = false;
			_constructionInProcess = false;
			joinsQueue = [];
			drawedNodesUids = [];

			trees = new TreesCollection(bus);
			matrixes = new MatrixCollection();
			generations = new GenerationsCollection(bus, matrixes);
		}
	}
}
