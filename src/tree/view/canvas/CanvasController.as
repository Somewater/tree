package tree.view.canvas {
	import flash.events.Event;

	import tree.command.Actor;
	import tree.command.Command;
	import tree.model.GenNode;
	import tree.model.Generation;
	import tree.model.Join;
	import tree.model.Node;

	public class CanvasController extends Actor{

		private var canvas:Canvas;

		public function CanvasController(canvas:Canvas) {
			this.canvas = canvas;
			detain();
		}

		public function drawJoin(g:GenNode):void {
			var n:NodeIcon = canvas.getNodeIcon(g.node.uid);
			if(!n){
				n = canvas.getNodeIconAndCreate(g);
				n.complete.addOnce(onNodeCompleteOnce);
			}

			g.node.positionChanged.add(onNodePositionChanged);
			g.generation.changed.add(onGenerationChanged);
		}

		private function onNodePositionChanged(node:Node):void {
			// саму иконку поправить
			var n:NodeIcon = canvas.getNodeIcon(node.uid);

			// все joinline переанимировать
			for each(var j:Join in node.iterator)
			{
				var l:JoinLine = canvas.getJoinLineAndCreate(j.from.uid, j.uid);
				l.hide();
			}

			n.complete.addOnce(onNodePositionComplete);
			n.refreshPosition();
		}

		private function onNodeCompleteOnce(n:NodeIcon):void {
			canvas.dispatchEvent(new Event(Event.COMPLETE));
		}

		private function onNodePositionComplete(n:NodeIcon):void {
			var node:Node = n.data.node;

			for each(var j:Join in node.iterator)
			{
				var l:JoinLine = canvas.getJoinLineAndCreate(j.from.uid, j.uid);
				l.show();
			}
		}

		private function onGenerationChanged(generation:Generation):void {
			canvas.refreshGenerations();

			for each(var g:GenNode in generation.iterator)
				onNodePositionChanged(g.node);
		}
	}
}
