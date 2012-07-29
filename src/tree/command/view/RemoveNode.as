package tree.command.view {
	import tree.command.Command;
	import tree.model.GenNode;
	import tree.model.Join;
	import tree.model.Person;
	import tree.signal.ViewSignal;

	public class RemoveNode extends Command{

		private var join:Join

		public function RemoveNode(join:Join) {
			this.join = join;
		}

		override public function execute():void {
			delete(model.drawedNodesUids[join.uid]);
			var g:GenNode = model.generations.get(join.associate.node.generation).removeWithJoin(join);

			model.trees.refreshTreeSizes(g.node.person, false);

			bus.dispatch(ViewSignal.REMOVE_JOIN, g);
		}
	}
}
