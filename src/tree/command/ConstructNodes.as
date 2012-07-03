package tree.command {
	import tree.model.Node;
	import tree.model.NodesCollection;
	import tree.model.Person;
	import tree.signal.ModelSignal;

	public class ConstructNodes extends Command{
		public function ConstructNodes() {
		}

		override public function execute():void {
			var nodes:NodesCollection = model.nodes;
			nodes.clear();
			var node:Node;
			var p:Person;

			for each(p in model.persons.iterator)
			{
				node = nodes.get(p.uid.toString());
				if(node == null)
				{
					node = nodes.allocate(p);
					nodes.add(node);
				}
			}

			bus.dispatch(ModelSignal.NODES_NEED_CALCULATE);
		}
	}
}
