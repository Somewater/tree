package tree.command.view {
	import tree.command.Command;
	import tree.model.Node;
	import tree.model.process.RollQueueProcessor;

	public class RollUnrollNode extends Command{

		protected var node:Node;

		public function RollUnrollNode(node:Node) {
			this.node = node;
		}

		override public function execute():void {
			// если не пуста очередь на построение, не делаем ничего
			if(model.joinsForDraw.length)
				return;

			detain();
			var processor:RollQueueProcessor = new RollQueueProcessor(model, node.person, onQueueCompleted);
		}

		private function onQueueCompleted():void {
			release();


		}
	}
}
