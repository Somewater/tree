package tree.command.view {
	import tree.command.*;
	import tree.model.Join;
	import tree.model.JoinType;
	import tree.model.Person;
	import tree.model.process.NodesProcessor;
	import tree.model.process.NodesProcessorResponse;
	import tree.model.process.SortedNodeProcessor;
	import tree.signal.ViewSignal;

	/**
	 * Начать построение дерева
	 */
	public class StartTreeDraw extends Command{
		public function StartTreeDraw() {
		}

		override public function execute():void {
			model.drawedNodesUids = [];
			var joinsForDraw:Array = model.joinsForDraw = [];

			// создаем специальную Join которая не имеет обратной ссылки, для пострения первого участника
			var firstPerson:Person = model.owner;
			var firstJoin:Join = new Join(model.persons);
			firstJoin.uid = firstPerson.uid;
			firstJoin.type = JoinType.FIRST_JOIN;// т.е. не имеет типа, не на кого ссылаться

			joinsForDraw.push(firstJoin);

			var proc:NodesProcessor = new SortedNodeProcessor(model, firstPerson,
					function(response:NodesProcessorResponse):void{
						var j:Join = response.fromSource;
						if(j)
						{
							// если это братская связь и родители тоже есть, то игнорировать (братья-сестры будут построены от родителей)
							if(j.type.superType == JoinType.SUPER_TYPE_BRO
									&& breedOfSome(response.source.person.parents, j.associate))
							{
								proc.dequeue(j.uid);
								return;
							}

							joinsForDraw.push(j);
						}
					})
			while(proc.process()){}

			proc.clear();
			model.joinsQueue = joinsForDraw.slice();

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
