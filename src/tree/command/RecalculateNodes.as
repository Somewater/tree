package tree.command {
	import tree.model.Join;
	import tree.model.Join;
	import tree.model.Node;
	import tree.model.NodesCollection;
	import tree.model.Person;
	import tree.signal.ModelSignal;

	/**
	 * Пересчет параметров позиционирования (Nodes) для ранее сконструированного дерева
	 * (т.е. связи между Persons уже должны быть готовы)
	 */
	public class RecalculateNodes extends Command{
		public function RecalculateNodes() {
		}

		override public function execute():void {
			var nodes:NodesCollection = model.nodes;
			nodes.clear();
			var node:Node;
			var p:Person;

			for each(p in model.persons.iterator)
			{
				node = nodes.get(p.uid.toString());
				if(node == null)
				{
					node = nodes.allocate(p);
					nodes.add(node);
				}
			}

			var processedUids:Array = [];
			var queuedUids:Array = [];

			var owner:Person = model.owner;
			var ownerNode:Node = nodes.get(owner.uid + '');
			ownerNode.d = 0;
			ownerNode.v = 0;
			ownerNode.vc = 0;
			processedUids[owner.uid] = true;// т.к. его параметры (равные нулям) уже определены

			var neighbours:Array = [owner];
			while(neighbours.length){
				var newNeighbours:Array = recalculateNeighbours(neighbours.pop(), processedUids, queuedUids, nodes);
				for each(p in newNeighbours)
					neighbours.push(p);
			}

			bus.dispatch(ModelSignal.NODES_RECALCULATED);
		}

		private function recalculateNeighbours(owner:Person, processedUids:Array, queuedUids:Array, nodes:NodesCollection):Array {
			var neighbours:Array = [];
			var ownerNode:Node = nodes.get(owner.uid + '');

			for each(var join:Join in owner.joins)
				if(!processedUids[join.uid])// не считаем дваджы во измежании циклов
				{
					var assoc:Person = join.associate;
					var assocNode:Node = nodes.get(assoc.uid + '');

					// назначаем параметры, относительно owner
					assocNode.d = ownerNode.d + 1;
					if(join.flatten)
						assocNode.v = ownerNode.v;
					else {
						if(join.breed)
							assocNode.v = -1;
						else
							assocNode.v = 1;
					}

					if(ownerNode.v != 0 && ownerNode.v + assocNode.v == 0)
						assocNode.vc = ownerNode.vc + 1;
					else
						assocNode.vc = ownerNode.vc;

					processedUids[join.uid] = true;

					// ассоциированных с этим человеком родственников добавлям к рассчету
					for each(var join2:Join in assoc.joins)
						if(!processedUids[join2.uid] && !queuedUids[join2.uid])
						{
							neighbours.push(join2.associate);
							queuedUids[join2.uid] = true;
						}
				}

			return neighbours;
		}
	}
}
