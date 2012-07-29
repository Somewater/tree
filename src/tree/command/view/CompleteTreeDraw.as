package tree.command.view {
	import tree.command.Command;
	import tree.signal.ViewSignal;

	public class CompleteTreeDraw extends Command{
		public function CompleteTreeDraw() {
		}

		override public function execute():void {
			bus.addCommand(ViewSignal.JOIN_DRAWED, ContinueTreeDraw);// TODO: убрать за ненадобностью после отказа от "N"
			log('Дерево построено');
		}
	}
}
