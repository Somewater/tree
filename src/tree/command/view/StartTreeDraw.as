package tree.command.view {
	import tree.command.*;
	import tree.model.Join;
	import tree.model.JoinType;
	import tree.model.Person;
	import tree.model.TreeModel;
	import tree.model.process.PersonsProcessor;
	import tree.model.process.NodesProcessorResponse;
	import tree.model.process.SortedPersonsProcessor;
	import tree.signal.ViewSignal;

	/**
	 * Начать построение дерева
	 */
	public class StartTreeDraw extends Command{

		private var tree:TreeModel;

		public function StartTreeDraw(tree:TreeModel) {
			this.tree = tree;
		}

		override public function execute():void {
			// должны быть закончены все предыдущие построения
			if(model.joinsForDraw.length || model.joinsForRemove.length)
				throw new Error('Preview process not completed: draw=' + model.joinsForDraw + ", remove=" + model.joinsForRemove);

			var joinsForDraw:Array = model.joinsForDraw = [];

			// создаем специальную Join которая не имеет обратной ссылки, для пострения первого участника
			var firstPerson:Person = tree.owner;
			var firstJoin:Join = new Join(tree.persons);
			firstJoin.associate = firstPerson;
			firstJoin.type = JoinType.FIRST_JOIN;// т.е. не имеет типа, не на кого ссылаться

			joinsForDraw.push(firstJoin);
			var depthIndex:int = model.depthIndex;

			var proc:PersonsProcessor = new SortedPersonsProcessor(tree, firstPerson,
					function(response:NodesProcessorResponse):void{
						var j:Join = response.fromSource;
						if(j)
						{
							if(depthIndex && response.node.dist > depthIndex)
								return;

							// если это братская связь и родители тоже есть, то игнорировать (братья-сестры будут построены от родителей)
							if(j.type.superType == JoinType.SUPER_TYPE_BRO
									&& breedOfSome(response.source.person.parents, j.associate))
							{
								proc.dequeue(j.uid);
								return;
							}

							response.node.join = j;
							joinsForDraw.push(j);
						}
					})
			while(proc.process()){}

			proc.clear();
			model.joinsQueue = model.joinsQueue.concat(joinsForDraw);
			model.animationQuality = model.trees.personQuantity > model.options.animQualityMedium ? (model.trees.personQuantity > model.options.animQualityLow ? 0 : 1) : 2;
			model.refrNodesVisibDelay = [10, 5, 3][model.animationQuality];
			model.refrNodesVisibForceDelay = [300, 120, 30][model.animationQuality];
			model.constructionInProcess = true;
			bus.dispatch(ViewSignal.JOIN_QUEUE_STARTED)
		}

		private function breedOfSome(parents:Array, breed:Person):Boolean{
			for each(var p:Person in parents)
				if(p.breeds.indexOf(breed) != -1)
					return true
			return false;
		}
	}
}
