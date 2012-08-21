package tree.command.view {
	import tree.command.Command;
	import tree.common.Config;
	import tree.model.Join;
	import tree.model.Node;
	import tree.model.process.RollQueueProcessor;
	import tree.signal.ViewSignal;
	import tree.view.canvas.INodeViewCollection;

	public class RollUnrollNode extends Command{

		protected var node:Node;

		public function RollUnrollNode(node:Node) {
			this.node = node;
		}

		override public function execute():void {
			// если не пуста очередь на построение, не делаем ничего
			if(model.joinsForDraw.length || model.joinsForRemove.length)
				return;


			var n:Node;
			var canvas:INodeViewCollection = Config.inject(INodeViewCollection);
			if(node.slavesUnrolled){
				node.slavesUnrolled = false;
				var visible:Array = [];
				for each(n in node.slaves)
					if(n.visible)
						visible.push(n.join)
				reverse(visible);
				model.joinsForRemove = model.joinsForRemove.concat(visible)
			}else{// hidden.length
				node.slavesUnrolled = true;
				var hidden:Array = [];
				for each(n in node.slaves)
					if(!n.visible && n.unrolled)
						hidden.push(n.join)
				model.joinsForDraw = model.joinsForDraw.concat(hidden)
			}

			node.fireRollChange();

			bus.dispatch(ViewSignal.JOIN_QUEUE_STARTED);
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
