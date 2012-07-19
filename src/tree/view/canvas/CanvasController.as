package tree.view.canvas {
	import flash.events.Event;

	import tree.command.Actor;
	import tree.command.Command;
	import tree.model.GenNode;
	import tree.model.Generation;
	import tree.model.Generation;
	import tree.model.Join;
	import tree.model.Join;
	import tree.model.JoinType;
	import tree.model.Node;
	import tree.view.canvas.JoinLine;
	import tree.view.canvas.NodeIcon;

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

			if(g.join.from){
				n.refreshPosition(false);
				n.hide(false);

				var l:JoinLine = canvas.getJoinLineAndCreate(g.join.from.uid, g.node.uid);
				l.data = g.join;
				l.complete.addOnce(onLineCompleteOnce);
				l.play()
			}else{
				// первая нода дерева
				n.refreshPosition(false);
				n.hide(false);
				n.show();
			}


			g.node.positionChanged.add(onNodePositionChanged);
			g.generation.changed.add(onGenerationChanged);
		}

		private function onNodePositionChanged(node:Node):void {
			// саму иконку поправить
			var n:NodeIcon = canvas.getNodeIcon(node.uid);
			if(!n){
				warn("Attempt refresh position of non existent node " + node);
				return;
			}

			// все joinline переанимировать
			for each(var j:Join in node.iterator)
			{
				var l:JoinLine = canvas.getJoinLineAndCreate(j.from.uid, j.uid);
				l.hide();
			}

			n.complete.addOnce(refreshNodeJoinLines);
			n.refreshPosition();
		}

		private function onLineCompleteOnce(line:JoinLine):void {
			var j:Join = line.data;
			var n:NodeIcon = canvas.getNodeIcon(j.associate.uid);
			n.show();
		}

		private function onNodeCompleteOnce(n:NodeIcon):void {
			refreshNodeJoinLines(n);
			canvas.dispatchEvent(new Event(Event.COMPLETE));
		}

		private function refreshNodeJoinLines(n:NodeIcon):void {
			var node:Node = n.data.node;
			var j:Join;
			var l:JoinLine;

			var linetToRefresh:Array = [];

			for each(j in node.iterator)
			{
				l = canvas.getJoinLineAndCreate(j.from.uid, j.uid);
				linetToRefresh.push(l);
			}

			// если рассматриваемая нода имеет супруга, обновить джоин-лайны детей
			if(node.marry){
				for each(j in node.marry.node.iterator){
					l = canvas.getJoinLineAndCreate(j.from.uid, j.uid);
					if(linetToRefresh.indexOf(l) == -1)
						linetToRefresh.push(l)
				}
			}

			for each(l in linetToRefresh){
				log("REFRESH JOIN " + l)
				l.show();
			}
		}

		private function onGenerationChanged(generation:Generation):void {
			canvas.refreshGenerations();

			// надо обновить ноды текущей generation и всех нижележащих
			for each(var gener:Generation in model.generations.iterator)
				if(gener.generation >= generation.generation)
					for each(var g:GenNode in gener.iterator)
						onNodePositionChanged(g.node);
		}
	}
}
