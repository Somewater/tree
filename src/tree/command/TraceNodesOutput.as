package tree.command {
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	import tree.model.NodesProcessor;
	import tree.model.NodesProcessorCallback;

	public class TraceNodesOutput extends Command{

		private var timer:Timer;

		public function TraceNodesOutput() {
		}

		override public function execute():void {
			debugTrace('Начинаем строить дерево...');

			var n:NodesProcessor = new NodesProcessor(model.owner, model, traceNode);
			n.start();
			detain();

			timer = new Timer(100);
			timer.addEventListener(TimerEvent.TIMER, function(event:Event):void{
				n.tick();
			});
			timer.start();
		}

		private function traceNode(nodes:NodesProcessorCallback):void {
			if(nodes)
			{
				debugTrace('Нарисовать ' +
						(nodes.relative ? nodes.current.person.get(nodes.relative.id)
								: nodes.current.person))
			}
			else
			{
				debugTrace('Дерево построено');
				timer.stop();
				release();
			}
		}
	}
}
