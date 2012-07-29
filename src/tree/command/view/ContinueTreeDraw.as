package tree.command.view {
	import tree.command.*;
	import tree.common.Config;
	import tree.manager.Ticker;
	import tree.model.GenNode;
	import tree.model.Join;
	import tree.model.JoinType;
	import tree.model.Node;
	import tree.model.NodesCollection;
	import tree.model.Person;
	import tree.model.SpatialMatrix;
	import tree.signal.ModelSignal;
	import tree.signal.ViewSignal;

	/**
	 * Продолжить построение дерева
	 */
	public class ContinueTreeDraw extends Command{
		public function ContinueTreeDraw() {
		}

		override public function execute():void {
			var join:Join = model.joinsForDraw.shift();
			if(join)
			{
				bus.dispatch(ModelSignal.ADD_NODE, join);
				return;
			}

			join = model.joinsForRemove.shift();
			if(join)
			{
				bus.dispatch(ModelSignal.REMOVE_NODE, join);
				return;
			}

			bus.dispatch(ViewSignal.JOIN_QUEUE_COMPLETED)
		}
	}
}
