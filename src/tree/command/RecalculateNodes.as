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
			var parent:Node = response.parent;
			if(parent) {
				// назначаем параметры, относительно owner
				node.d = parent.d + 1;
				if(response.fromParent.flatten)
					node.v = parent.v;
				else {
					if(response.fromParent.breed)
						node.v = -1;
					else
						node.v = 1;
				}

				if(parent.v != 0 && parent.v + node.v == 0)
					node.vc = parent.vc + 1;
				else
					node.vc = parent.vc;
			} else {
				node.d = 0;
				node.v = 0;
				node.vc = 0;
			}
		}
	}
}
