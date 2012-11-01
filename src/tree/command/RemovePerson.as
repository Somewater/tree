package tree.command {
	import tree.model.Join;
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
			var tree:TreeModel = person.tree;
			tree.nodes.remove(person.node);
			tree.persons.remove(person);

			// todo: отовсюду (nodes, persons) удалить джоины, в nodes отыскать  join, которая ссылается на удаляемую person
			var join:Join

			var request:RequestSignal = new RequestSignal(RequestSignal.DELETE_USER);
			request.person = person;
			call(request);

			// todo: всем нодам затронутым в удалении джоинов пересчитать джоины (возможно изменится их статус в дереве)
			//RecalculateNodes.calculate(node, join.associate.node, join.flatten, join.breed);

			bus.dispatch(ModelSignal.HIDE_NODE, join);
		}
	}
}
