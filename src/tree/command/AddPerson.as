package tree.command {
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
			var tree:TreeModel = join.from.tree;
			join.associate.tree = tree;
			var node:Node = tree.nodes.allocate(join.associate);
			tree.nodes.add(node);

			var alterJoin:Join = new Join(tree.persons);
			alterJoin.uid = join.from.uid;
			alterJoin.from = join.associate;
			alterJoin.type = Join.toAlter(join.type, join.associate.male);

			join.associate.add(alterJoin);
			join.from.add(join);

			var request:RequestSignal = new RequestSignal(RequestSignal.ADD_USER);
			request.addedJoin = join;
			call(request);

			RecalculateNodes.calculate(node, join.associate.node, join.flatten, join.breed);

			bus.dispatch(ModelSignal.SHOW_NODE, join);
		}
	}
}
