package tree.command {
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	import tree.model.process.NodesProcessor;
	import tree.model.process.NodesProcessorResponse;

	public class TraceNodesOutput extends Command{

		private var timer:Timer;

		public function TraceNodesOutput() {
		}

		override public function execute():void {
			debugTrace('Начинаем строить дерево...');

			var n:NodesProcessor = new NodesProcessor(model, model.owner, traceNode);
			detain();

			timer = new Timer(100);
			timer.addEventListener(TimerEvent.TIMER, function(event:Event):void{
				if(!n.process()) {
					debugTrace('Дерево построено');
					timer.stop();
					release();
					n.clear();
				}
			});
			timer.start();
		}

		private function traceNode(nodes:NodesProcessorResponse):void {
			debugTrace('Нарисовать ' +
					(nodes.parent ? nodes.node.person.get(nodes.parent.id)
							: nodes.node.person))
		}
	}
}
