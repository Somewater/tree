package tree.command {
import tree.common.Config;
import tree.model.Join;
import tree.model.JoinCollectionBase;
import tree.model.Node;
import tree.model.Person;
	import tree.model.TreeModel;
	import tree.signal.ModelSignal;
	import tree.signal.RequestSignal;

	public class RemovePerson extends Command{

		private var person:Person;

		public function RemovePerson(person:Person) {
			this.person = person;
		}

		override public function execute():void {
			// todo: отовсюду (nodes, persons) удалить джоины, в nodes отыскать  join, которая ссылается на удаляемую person
			var join:Join;
			for each(join in model.joinsQueue)
				if(join.associate == person)
					break;

			var request:RequestSignal = new RequestSignal(RequestSignal.DELETE_USER);
			request.person = person;
			call(request);

			// todo: всем нодам затронутым в удалении джоинов пересчитать джоины (возможно изменится их статус в дереве)
			//RecalculateNodes.calculate(node, join.associate.node, join.flatten, join.breed);

			bus.dispatch(ModelSignal.HIDE_NODE, join);

			detain();
			Config.ticker.callLater(removePersonFromModel, 100);
			model.treeViewConstructed = false;
		}

		private function removePersonFromModel():void{
			release();

			var tree:TreeModel = person.tree;
			var node:Node = person.node;
			tree.nodes.remove(person.node);
			tree.persons.remove(person);
			model.treeViewConstructed = true;

			for each(var n:Node in tree.nodes.iterator){
				if(n.slaves){
					var idx:int = n.slaves.indexOf(node);
					if(idx != -1)
						n.slaves.splice(idx, 1);
				}
			}
		}
	}
}
