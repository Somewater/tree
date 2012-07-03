package tree.model {
	import flash.geom.Point;
	import flash.geom.Point;

	import tree.common.Bus;
	import tree.model.base.IModel;
	import tree.model.base.ModelCollection;
	import tree.model.SpatialMatrix;

	/**
	 * Коллекция GenNode
	 */
	public class Generation extends ModelCollection{

		protected var matrixes:MatrixCollection;

		public function Generation(persons:PersonsCollection, bus:Bus, matrixes:MatrixCollection) {
			super();
			this.matrixes = matrixes;
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
		public function addWithJoin(node:Node, join:Join):void {
			var g:GenNode = new GenNode(node, join);
			add(g);
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

		}
	}
}
