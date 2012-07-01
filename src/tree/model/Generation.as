package tree.model {
	import tree.common.Bus;
	import tree.model.base.IModel;
	import tree.model.base.ModelCollection;
	import tree.model.base.SpatialMatrix;

	/**
	 * Коллекция GenNode
	 */
	public class Generation extends ModelCollection{

		protected var matrix:SpatialMatrix;

		public function Generation(persons:PersonsCollection, bus:Bus) {
			super();
			matrix = new SpatialMatrix();
		}

		/**
		 * Также расчитывает изменение пространственных параметров удаляемой ноды
		 * и всех остальных (она могла их затронуть)
		 * @param model
		 */
		override public function remove(model:IModel):void {
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
			super.remove(model);
			recalculate();
		}

		override public function add(model:IModel):void {
			if(!(model is GenNode))
				throw new Error('Only GenNode can be added');
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

		protected function recalculate():void {

		}
	}
}
