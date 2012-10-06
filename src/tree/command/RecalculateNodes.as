package tree.command {
	import flash.utils.getTimer;

	import tree.common.Config;
	import tree.model.ModelBase;

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

		private var precessors:Array = [];
		private var farPersonsForDelete:Array = [];
		private var nearPersonCounterPerTree:int
		private var currentTree:TreeModel;

		private var nodesPersentCounter:int = 0;
		private var nodesPersentQuantity:int
		private var nodesForDeletePersentQuantity:int;

		public function RecalculateNodes() {
		}

		override public function execute():void {
			for each(var tree:TreeModel in model.trees.iterator){
				var proc:PersonsProcessor = new PersonsProcessor(tree, tree.owner, calculateNode);
				precessors.push(proc);
			}
			nodesPersentQuantity = model.trees.personQuantity;
			bus.initialLoadingProgress.dispatch(3, 0);
			Config.ticker.callLater(tick);
		}

		private function tick():void{
			var counter:int = 1;
			var time:Number = getTimer();

			while(precessors.length){
				var proc:PersonsProcessor = precessors[0];
				while(proc.process())
				{
					if(counter++ % 100 == 0 && (getTimer() - time) > 200){
						bus.initialLoadingProgress.dispatch(3, 0.8 * (nodesPersentCounter / nodesPersentQuantity));
						Config.ticker.callLater(tick);
						return;
					}
				}
				proc.clear();
				this.precessors.shift()
			}

			nodesForDeletePersentQuantity = farPersonsForDelete.length;
			Config.ticker.callLater(removeFarPersons);
		}

		private function removeFarPersons():void{
			var p:Person;
			var counter:int = 1;
			var time:Number = getTimer();

			while(farPersonsForDelete.length){
				p = farPersonsForDelete.pop();
				deletePerson(p);

				if(counter++ % 100 == 0 && (getTimer() - time) > 200){
					bus.initialLoadingProgress.dispatch(3, 0.8 + 0.2 * (farPersonsForDelete.length / nodesForDeletePersentQuantity));
					Config.ticker.callLater(removeFarPersons);
					return;
				}
			}

			detain();
			clear();
			ModelBase.radioSilence = false;

			bus.initialLoadingProgress.dispatch(3, 1);
			Config.ticker.callLater(bus.dispatch, 1, [ModelSignal.NODES_RECALCULATED]);
		}

		private function calculateNode(response:NodesProcessorResponse):void {
			nodesPersentCounter++;

			if(response.fromSource)
				calculate(response.node, response.source, response.fromSource.flatten, response.fromSource.breed);
			else
				calculate(response.node, null, false, false);

			if((nearPersonCounterPerTree > 500 && currentTree == response.node.person.tree)
					|| response.node.dist > 10
					|| Math.abs(response.node.generation) > 10){
				farPersonsForDelete.push(response.node.person);
			}else
				nearPersonCounterPerTree++;

			if(currentTree != response.node.person.tree){
				currentTree = response.node.person.tree
				nearPersonCounterPerTree = 0;
			}
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

		private function clear():void{
			farPersonsForDelete = null;
			precessors = null;
		}

		private function deletePerson(p:Person):void {
			for each(var j:Join in p.iterator){
				j.associate.remove(j.associate.relation(p))
			}
			p.tree.nodes.remove(p.node);
			p.tree.persons.remove(p);
			p.tree = null;
			p.clear();
		}
	}
}
