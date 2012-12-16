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
		private var minLevelNumber:int;
		private var maxLevelNumber:int;

		public function Generation(collection:GenerationsCollection, generation:int, bus:Bus, matrixes:MatrixCollection) {
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
			matrixes.byLevelAndTree(g.node.level, g.node.person.tree).remove(g);
			super.remove(model);
			recalculate();
		}

		override public function add(model:IModel):void {
			var g:GenNode = model as GenNode;
			if(!g)
				throw new Error('Only GenNode can be added');

			var p:Point = matrixes.byLevelAndTree(g.node.level, g.node.person.tree).add(g);
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
		public function addWithJoin(join:Join):GenNode {
			var g:GenNode = new GenNode(join, this);
			add(g);
			return g;
		}

		public function removeWithJoin(join:Join):GenNode {
			var g:GenNode
			for each(var _g:GenNode in array)
					if(join && join == _g.join){
						g = _g;
						break;
					}
			remove(g)
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

		public function recalculate():void {
			var newLevelNum:int = 0;
			var levelsHash:Array = [];
			var levels:Array = [];
			var hand:Boolean = Model.instance.hand;
			for each(var icon:GenNode in array) {
				var value:int = hand ? icon.node.handY : icon.node.level;
				if((!hand || value != int.MAX_VALUE) && !levelsHash[value])
				{
					levelsHash[value] = true;
					levels.push(value);
					newLevelNum++;
				}
			}

			if(_levelNum != newLevelNum){
				_levelNum = newLevelNum;
				levelNumbers = [];
				levels.sort(Array.NUMERIC);
				var j:int;
				maxLevelNumber = int.MIN_VALUE;
				minLevelNumber = int.MAX_VALUE;
				for each(var i:int in levels){
					levelNumbers[i] = j++;
					if(maxLevelNumber < i) maxLevelNumber = i;
					if(minLevelNumber > 0) minLevelNumber = i;
				}
				fireChange();
			}
		}

		public function get levelNum():int {
			return _levelNum;
		}

		public function getY(desc:Boolean):int {
			if(generation == 0) return 0;
			var value:int;
			var vector:int;
			var i:int;
			if(desc){
				value = generation > 0 ? collection.get(0)._levelNum : 0;
				vector = value > 0 ? -1 : 1;
				for (i = generation < 0 ? generation : generation - 1;
					 i != 0;
					 i += vector) {
					value += collection.get(i)._levelNum;
				}
				return generation < 0 ? -value : value;
			}else{
				value = generation < 0 ? collection.get(0)._levelNum : 0;
				vector = value > 0 ? 1 : -1;
				for (i = generation < 0 ? generation + 1 : generation;
					 i != 0;
					 i += vector) {
					value += collection.get(i)._levelNum;
				}
				return generation > 0 ? -value : value;
			}
		}

		/**
		 * Преобразует номер левела (число -oo ... 0 ...  +oo) в величину типа [0... +oo],
		 * где 0 соответствует наименьшему левелу из всех нод, содержащихся в Generation
		 */
		public function normalize(level:int):int {
			var value:* = levelNumbers[level];
			if(value === undefined){
				if(level > maxLevelNumber)
					return levelNumbers[maxLevelNumber] + (level - maxLevelNumber);
				else
					return 0;
			}
			return value;
		}

		public function denormalize(y:int):int {
			for(var key:String in levelNumbers){
				var value:int = levelNumbers[key];
				if(value == y)
					return parseInt(key);
			}
			var diff:int = levelNumbers[maxLevelNumber] - y;
			if(diff < 0)
				return maxLevelNumber + Math.abs(diff);
			else{
				diff = y - levelNumbers[minLevelNumber];
				return minLevelNumber + y;
			}
		}
	}
}
