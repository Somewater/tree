package tree.command {
	import tree.model.Node;
	import tree.model.NodesCollection;
	import tree.model.Person;
	import tree.model.TreeModel;
	import tree.signal.ModelSignal;

	public class ConstructNodes extends Command{
		public function ConstructNodes() {
		}

		override public function execute():void {

			var node:Node;
			var p:Person;
			var tree:TreeModel;

			for each(tree in model.trees.iterator) {
				for each(p in tree.persons.iterator) {
					node = tree.nodes.get(p.uid.toString());
					if(node == null) {
						node = tree.nodes.allocate(p);
						tree.nodes.add(node);
					}
				}
			}

			bus.dispatch(ModelSignal.NODES_NEED_CALCULATE);
		}
	}
}
