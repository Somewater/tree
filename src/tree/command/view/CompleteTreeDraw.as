package tree.command.view {
	import tree.command.Command;
	import tree.signal.ViewSignal;

	public class CompleteTreeDraw extends Command{
		public function CompleteTreeDraw() {
		}

		override public function execute():void {
			bus.removeCommand(ViewSignal.ALL_TREES_COMPLETED, CompleteTreeDraw);
			log('Дерево построено');

			bus.dispatch(ViewSignal.RECALCULATE_ROLL_UNROLL);
		}
	}
}
