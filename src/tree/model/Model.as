package tree.model {
	import flash.geom.Point;
	import flash.geom.Point;

	import tree.Tree;

	import tree.common.Bus;
	import tree.common.Config;
	import tree.model.base.ModelCollection;
	import tree.signal.ViewSignal;

	public class Model {

		public var trees:TreesCollection;
		public var generations:GenerationsCollection;
		public var matrixes:MatrixCollection;
		private var _zoom:Number = 1;
		public var zoomCenter:Point = new Point();
		private var _mousePosition:Point = new Point();
		private var _guiOpen:Boolean = true;

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
		private var _treeViewConstructed:Boolean = false;// первоначальное построение дерева завершено
		private var _constructionInProcess:Boolean = false;// произвоится анимация (построение дерева или сворачивание-разворачивание)
		private var _selectedPerson:Person;

		public var animationQuality:int = 2;// "0" - без анимации, "2" - полная анимация, "1" - зарезервировано

		public var joinsQueue:Array = [];

		/**
		 * соединения, которые уже были нарисованы
		 */
		public var drawedNodesUids:Array = [];

		public var bus:Bus;

		public static var instance:Model;
		public var editing:ProfileEditingModel;

		public function Model(bus:Bus) {
			if(instance)
				throw new Error('Must be only one');
			instance = this;
			this.bus = bus;
			trees = new TreesCollection(bus);
			matrixes = new MatrixCollection();
			generations = new GenerationsCollection(bus, matrixes);
			editing = new ProfileEditingModel();

			bus.addNamed(ViewSignal.PERSON_SELECTED, onPersonSelected);
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


		private var _zoomDispatchOrdered:Boolean = false;
		public function set zoom(value:Number):void {
			value = Math.max(0.1, Math.min(1, value));
			if(value != _zoom) {
				_zoom = value;
				if(!_zoomDispatchOrdered){
					Config.ticker.callLater(dispatchZoomChange, 5);
					_zoomDispatchOrdered = true;
				}
			}
		}

		private function dispatchZoomChange():void{
			bus.zoom.dispatch(_zoom);
			_zoomDispatchOrdered = false;
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
			_selectedPerson = null;

			trees = new TreesCollection(bus);
			matrixes = new MatrixCollection();
			generations = new GenerationsCollection(bus, matrixes);
		}

		private function onPersonSelected(person:Person):void{
			_selectedPerson = person;
		}


		public function get selectedPerson():Person {
			return _selectedPerson;
		}

		public function set selectedPerson(value:Person):void {
			if(value != _selectedPerson){
				if(_selectedPerson)
					bus.dispatch(ViewSignal.PERSON_DESELECTED, _selectedPerson);
				_selectedPerson = value;
				if(_selectedPerson)
					bus.dispatch(ViewSignal.PERSON_SELECTED, _selectedPerson);
			}
		}

		public function get guiOpen():Boolean {
			return _guiOpen;
		}

		public function set guiOpen(value:Boolean):void {
			if(value != _guiOpen){
				_guiOpen = value;
				bus.guiChanged.dispatch(_guiOpen);
				bus.onResize(null);
			}
		}

		public function get contentWidth():int{
			return _guiOpen ? Config.WIDTH - Config.GUI_WIDTH : Config.WIDTH;
		}
	}
}
