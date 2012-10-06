package tree.command.view {
	import tree.command.Command;
	import tree.signal.ViewSignal;

	public class CompleteTreeDraw extends Command{
		public function CompleteTreeDraw() {
		}

		override public function execute():void {
			log('Дерево построено. Персон: ' + model.trees.personQuantity);
			model.treeViewConstructed = true;
			model.constructionInProcess = false;

			bus.dispatch(ViewSignal.RECALCULATE_ROLL_UNROLL);
		}
	}
}
