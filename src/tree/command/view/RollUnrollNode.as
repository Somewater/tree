package tree.command.view {
	import tree.command.Command;
	import tree.model.Join;
	import tree.model.Node;
	import tree.model.process.RollQueueProcessor;
	import tree.signal.ViewSignal;

	public class RollUnrollNode extends Command{

		protected var node:Node;

		public function RollUnrollNode(node:Node) {
			this.node = node;
		}

		override public function execute():void {
			// если не пуста очередь на построение, не делаем ничего
			if(model.joinsForDraw.length || model.joinsForRemove.length)
				return;

			detain();
			var processor:RollQueueProcessor = new RollQueueProcessor(model, node.person, onQueueCompleted);
		}

		private function onQueueCompleted(queue:Array):void {
			release();

			if(queue.length){
				// если указанные ноды свернуты, развернуть их. Иначе свернуть
				var visible:Array = [];
				var hidden:Array = [];

				for each(var j:Join in queue){
					if(model.drawedNodesUids[j.uid])
						visible.push(j);
					else
						hidden.push(j);
				}

				if(hidden.length == 0 && visible.length == 0){
					error("Node " + node + " has wrong roll-unroll queue. Roll: " + hidden + ", Unroll: " + visible);
					return;
				}else if(visible.length){
					reverse(visible);
					model.joinsForRemove = model.joinsForRemove.concat(visible)
				}else{// hidden.length
					model.joinsForDraw = model.joinsForDraw.concat(hidden)
				}

				bus.dispatch(ViewSignal.JOIN_QUEUE_STARTED);
			}
		}

		private function reverse(a:Array):void {
			var left:int = 0;
			var right:int = a.length-1;
			while (left < right) {
				var temp:* = a[left];
				a[left] = a[right];
				a[right] = temp;
				left++; right--;
			}
		}
	}
}
