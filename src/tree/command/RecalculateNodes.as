package tree.command {
	import tree.model.TreeModel;
	import tree.model.process.PersonsProcessor;
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
			for each(var tree:TreeModel in model.trees.iterator){
				var proc:PersonsProcessor = new PersonsProcessor(tree, tree.owner, calculateNode);
				while(proc.process())
				{

				}
				proc.clear();
			}
			bus.dispatch(ModelSignal.NODES_RECALCULATED);
		}

		private function calculateNode(response:NodesProcessorResponse):void {
			if(response.fromSource)
				calculate(response.node, response.source, response.fromSource.flatten, response.fromSource.breed);
			else
				calculate(response.node, null, false, false);
		}

		public static function calculate(node:Node, source:Node, flatten:Boolean, breed:Boolean):void{
			if(source) {
				// назначаем параметры, относительно owner
				node.dist = source.dist + 1;
				if(flatten) {
					node.vector = source.vector;
					node.generation = source.generation;
				} else {
					if(breed) {
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
