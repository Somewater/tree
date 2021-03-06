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

		public var currentDate:Date = new Date();

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
		public var centreOwnerNode:Boolean = true;// центрировать офнера дерева в процессе построения дерева
		private var _selectedPerson:Person;
		private var _highlightedPerson:Person;
		private var _selectedTree:TreeModel;

		public var animationQuality:int = 2;// "0" - без анимации, "2" - полная анимация, "1" - зарезервировано
		public var refrNodesVisibDelay:int = 10;
		public var refrNodesVisibForceDelay:int = 10;

		public var joinsQueue:Array = [];
		public var rollUnrollAvailable:Boolean = false;// можно сворачивать-разворачивать ноды, т.к. инфа по ним пересчитана

		/**
		 * соединения, которые уже были нарисованы
		 */
		public var drawedNodesUids:Array = [];

		public var bus:Bus;

		public static var instance:Model;
		public var editing:ProfileEditingModel;

		public var depthIndex:int = 0;

		private var _descending:Boolean = true;// нисходящее дерево (дети ниже родителей)

		public var options:Options = new Options();

		private var _hand:Boolean = false;
		public var handLog:HandMovingLog;

		public var canvasMovingCounter:int = 1;

		CONFIG::debug{
			public static const DEFAULT_UID:int = 12178709//18985299;
		}

		public function Model(bus:Bus) {
			if(instance)
				throw new Error('Must be only one');
			instance = this;
			this.bus = bus;
			trees = new TreesCollection(bus);
			matrixes = new MatrixCollection();
			generations = new GenerationsCollection(bus, matrixes);
			editing = new ProfileEditingModel();
			handLog = new HandMovingLog();

			bus.addNamed(ViewSignal.PERSON_SELECTED, onPersonSelected);
			bus.addNamed(ViewSignal.PERSON_HIGHLIGHTED, onPersonHighlighted);
		}

		/**
		 * Кто запустил приложение
		 * @return
		 */
		public function get user():Person {
			if(!_user){
				_user = new Person(null);
				_user.uid = options.userId;
				CONFIG::debug{
					_user.uid ||= DEFAULT_UID;
				}
			}
			if(owner && owner.uid == _user.uid && _user != owner){
				_user = owner;
			}
			return _user;
		}
		private var _user:Person;

		public function get zoom():Number {
			return _zoom;
		}


		private var _zoomDispatchOrdered:Boolean = false;
		public function set zoom(value:Number):void {
			value = Math.max(options.zoomMin, Math.min(options.zoomMax, value));
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
				if(value) centreOwnerNode = false
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
			return trees && trees.first ? trees.first.owner : null;
		}

		public function utilize():void{
			joinsForDraw = [];
			joinsForRemove = [];
			_treeViewConstructed = false;
			_constructionInProcess = false;
			joinsQueue = [];
			drawedNodesUids = [];
			_selectedPerson = null;
			_highlightedPerson = null;
			_selectedTree = null;

			trees = new TreesCollection(bus);
			matrixes = new MatrixCollection();
			generations = new GenerationsCollection(bus, matrixes);
		}

		private function onPersonSelected(person:Person):void{
			_selectedPerson = person;
		}

		private function onPersonHighlighted(person:Person):void{
			_highlightedPerson = person;
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

		public function get highlightedPerson():Person {
			return _highlightedPerson;
		}

		public function set highlightedPerson(value:Person):void {
			if(value != _highlightedPerson){
				_highlightedPerson = value;
				bus.dispatch(ViewSignal.PERSON_HIGHLIGHTED, _highlightedPerson);
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

		public function get selectedTree():TreeModel {
			return _selectedTree;
		}

		public function set selectedTree(value:TreeModel):void {
			if(value != _selectedTree){
				if(_selectedTree)
					bus.dispatch(ViewSignal.TREE_DESELECTED, _selectedTree);
				_selectedTree = value;
				if(_selectedTree)
					bus.dispatch(ViewSignal.TREE_SELECTED, _selectedTree);
			}
		}


		public function get descending():Boolean {
			return _descending;
		}

		public function set descending(value:Boolean):void {
			if(value != _descending){
				_descending = value;
				bus.dispatch(ViewSignal.DESCENDING_CHANGED);
			}
		}

		public function get descendingInt():int{
			return _descending ? 1 : -1
		}

		public function get hand():Boolean {
			return _hand;
		}

		public function set hand(value:Boolean):void {
			if(_hand != value){
				_hand = value;
				bus.dispatch(ViewSignal.HAND_CHANGED);
				bus.hand.dispatch();
			}
		}

		/**
		 * Просматриваемое в данный момент дерево строится относительно авторизованного пользователя
		 */
		public function get isUserOwedTree():Boolean {
			return user && owner ? user.uid == owner.uid : false;
		}

		/**
		 * Время на сервере
		 */
		public function get serverTime():Date{
			var time:Number = options.currentTime * 1000;
			if(time == 0)
				time = new Date().time;
			return new Date(time);
		}
	}
}
