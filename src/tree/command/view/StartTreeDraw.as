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
			model.drawedJoins = [];
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
							if(j.type.superType == JoinType.SUPER_TYPE_BRO && response.source.person.parents.length)
								return;

							joinsForDraw.push(j);
						}
					})
			while(proc.process()){}

			proc.clear();

			bus.dispatch(ViewSignal.JOIN_QUEUE_STARTED)
		}
	}
}
