package tree.command {
import tree.manager.Logic;
import tree.model.Join;
	import tree.model.Node;
	import tree.model.TreeModel;
	import tree.signal.ModelSignal;
	import tree.signal.RequestSignal;

	public class AddPerson extends Command{

		private var join:Join;

		public function AddPerson(join:Join) {
			this.join = join;
		}

		override public function execute():void {
			addToModel(join);

			var request:RequestSignal = new RequestSignal(RequestSignal.ADD_USER);
			request.person = join.associate;
			call(request);

			bus.dispatch(ModelSignal.SHOW_NODE, join);
		}

		public static function addToModel(join:Join):void {
			var tree:TreeModel = join.from.tree;
			join.associate.tree = tree;
			var node:Node = tree.nodes.allocate(join.associate);
			node.join = join;
			tree.persons.add(join.associate);
			tree.nodes.add(node);


			var alterJoin:Join = new Join(tree.persons);
			alterJoin.associate = join.from;
			alterJoin.from = join.associate;
			alterJoin.type = Join.toAlter(join.type, join.associate.male);

			join.associate.add(alterJoin);
			join.from.add(join);

			Logic.calculateNode(node, join.associate.node, join.flatten, join.breed);
		}
	}
}
