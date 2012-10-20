package tree.command.view {
	import tree.command.Command;
	import tree.signal.ViewSignal;

	/**
	 * Мгновенно обновить позиции всех нод и перерисовать вче линии связей (например, при смене descending дерева)
	 */
	public class RefreshNodePositions extends Command{
		public function RefreshNodePositions() {
		}

		override public function execute():void {
			bus.dispatch(ViewSignal.REFRESH_GENERATIONS);
			bus.dispatch(ViewSignal.REFRESH_JOIN_LINES);
			bus.dispatch(ViewSignal.REFRESH_NODE_POSITIONS);
		}
	}
}
