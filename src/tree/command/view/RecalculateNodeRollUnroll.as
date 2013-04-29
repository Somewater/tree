package tree.command.view {
	import tree.command.Command;
	import tree.common.Config;
	import tree.signal.ViewSignal;
	import tree.view.canvas.INodeViewCollection;
	import tree.view.canvas.NodeIcon;

	/**
	 * Скрыть все кнопки roll-unroll, начать пересчет
	 */
	public class RecalculateNodeRollUnroll extends Command{
		public function RecalculateNodeRollUnroll() {
		}

		override public function execute():void {
			var canvas:INodeViewCollection = Config.inject(INodeViewCollection);
			for each(var node:NodeIcon in canvas.iterator) {
				node.hideRollUnroll();
				node.data.node.slaves = null;
				node.data.node.lords = null;
				//node.data.node.slavesUnrolled = true;
				node.data.node.fireRollChange();
			}

			model.rollUnrollAvailable = false;
			if(model.depthIndex == 0)
				bus.dispatch(ViewSignal.CALCULATE_NEXT_ROLL_UNROLL);
		}
	}
}
