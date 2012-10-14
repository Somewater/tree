package tree.command.view {
	import tree.command.Command;
	import tree.command.UtilizeTree;
	import tree.common.Config;
	import tree.model.Node;
	import tree.model.TreeModel;
	import tree.model.TreesCollection;
	import tree.signal.ModelSignal;

	public class DepthIndexChanged extends Command{

		private var newDepthIndex:int

		public function DepthIndexChanged(newDepthIndex:int) {
			this.newDepthIndex = newDepthIndex;
		}

		override public function execute():void {
			model.depthIndex = newDepthIndex;

			// сохраняем деревья
			var trees:TreesCollection = model.trees;
			new UtilizeTree().execute();
			model.trees = trees;

			// пометить как невидимые (так и есть на самом деле)
			for each(var t:TreeModel in trees.iterator){
				t.visible = false;
				for each(var n:Node in t.nodes.iterator){
					n.visible = false;
					n.slaves = null;
					n.lords = null;
					n.slavesUnrolled = true;
				}
			}

		   	Config.ticker.callLater(bus.dispatch, 1, [ModelSignal.NODES_RECALCULATED]);
		}
	}
}
