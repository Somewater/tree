package tree.command {
	import tree.model.process.NodesProcessor;
	import tree.model.Join;
	import tree.model.Join;
	import tree.model.Node;
	import tree.model.NodesCollection;
	import tree.model.process.NodesProcessorResponse;
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
			var proc:NodesProcessor = new NodesProcessor(model, model.owner, calculateNode);
			while(proc.process())
			{

			}
			proc.clear();
			bus.dispatch(ModelSignal.NODES_RECALCULATED);
		}

		private function calculateNode(response:NodesProcessorResponse):void {
			var node:Node = response.node;
			var source:Node = response.source;
			if(source) {
				// назначаем параметры, относительно owner
				node.dist = source.dist + 1;
				if(response.fromSource.flatten) {
					node.vector = source.vector;
					node.generation = source.generation;
				} else {
					if(response.fromSource.breed) {
						node.vector = -1;
						node.generation = source.generation + 1;
					} else {
						node.vector = 1;
						node.generation = source.generation - 1;
					}
				}

				if(source.vector != 0 && source.vector + node.vector == 0)
					node.vectCount = source.vectCount + 1;
				else
					node.vectCount = source.vectCount;
			} else {
				node.generation = 0;
				node.dist = 0;
				node.vector = 0;
				node.vectCount = 0;
			}
		}
	}
}
