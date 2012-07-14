package tree.model {
	import flash.geom.Point;
	import flash.geom.Point;

	import tree.common.Bus;
	import tree.model.GenerationsCollection;
	import tree.model.base.IModel;
	import tree.model.base.ModelCollection;
	import tree.model.SpatialMatrix;

	/**
	 * Коллекция GenNode
	 */
	public class Generation extends ModelCollection{

		public var generation:int;
		private var collection:GenerationsCollection
		protected var matrixes:MatrixCollection;


		private var _levelNum:int = 0;
		private var levelNumbers:Array = [];

		public function Generation(collection:GenerationsCollection, generation:int, persons:PersonsCollection, bus:Bus, matrixes:MatrixCollection) {
			super();
			this.collection = collection;
			this.generation = generation;
			this.matrixes = matrixes;
			this.fireChangeIfQuantityChanged =false;
		}


		override public function get id():String {
			return generation + '';
		}

		/**
		 * Также расчитывает изменение пространственных параметров удаляемой ноды
		 * и всех остальных (она могла их затронуть)
		 * @param model
		 */
		override public function remove(model:IModel):void {
			var g:GenNode = model as GenNode;
			if(!g)
				throw new Error('Only GenNode can be removed');
			matrixes.byLevel(g.node.level).remove(g);
			super.remove(model);
			recalculate();
		}

		override public function add(model:IModel):void {
			var g:GenNode = model as GenNode;
			if(!g)
				throw new Error('Only GenNode can be added');

			var p:Point = matrixes.byLevel(g.node.level).add(g);
			g.node.x = p.x;
			g.node.y = g.node.generation;

			super.add(model);
			recalculate();
		}

		/**
		 * Также расчитывает изменение пространственных параметров новой ноды
		 * и всех остальных (она могла их затронуть)
		 * @param model
		 */
		public function addWithJoin(node:Node, join:Join):GenNode {
			var g:GenNode = new GenNode(node, join, this);
			add(g);
			return g;
		}

		/**
		 * Использовать ф-ю, не зная GenNode, но зная принадлежащие ей Node или Join
		 */
		public function removeIModel(model:IModel):void {
			if(!(model is GenNode)) {
				var node:Node = model as Node;
				var join:Join = model as Join;
				if(!node && !join)
					throw new Error('Remove onlu GenNode, Node or Join');
				for each(var g:GenNode in array)
					if((node && g.node == node) || (join && join == g.join)){
						model = g;
						break;
					}
				if(!(model is GenNode))
					throw new Error('Can`t find related GenNode');
			}
			remove(model);
		}

		protected function recalculate():void {
			var newLevelNum:int = 0;
			var levelsHash:Array = [];
			var levels:Array = [];
			for each(var icon:GenNode in array) {
				if(!levelsHash[icon.node.level])
				{
					levelsHash[icon.node.level] = true;
					levels.push(icon.node.level);
					newLevelNum++;
				}
			}

			if(_levelNum != newLevelNum){
				_levelNum = newLevelNum;
				levelNumbers = [];
				levels.sort(Array.NUMERIC);
				var j:int;
				for each(var i:int in levels)
					levelNumbers[i] = j++;
				fireChange();
			}
		}

		public function get levelNum():int {
			return _levelNum;
		}

		public function get y():int {
			if(generation == 0) return 0;
			var value:int = generation > 0 ? collection.get(0)._levelNum : 0;
			var vector:int = value > 0 ? -1 : 1;
			for (var i:int = generation < 0 ? generation : generation - 1;
				 i != 0;
				 i += vector) {
				value += collection.get(i)._levelNum;
			}
			return generation < 0 ? -value : value;
		}

		/**
		 * Преобразует номер левела (число -oo ... 0 ...  +oo) в величину типа [0... +oo],
		 * где 0 соответствует наименьшему левелу из всех нод, содержащихся в Generation
		 */
		public function normalize(level:int):int {
			return levelNumbers[level];
		}
	}
}
