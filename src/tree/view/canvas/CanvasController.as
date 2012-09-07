package tree.view.canvas {
	import com.gskinner.motion.GTweener;

	import flash.events.Event;
	import flash.geom.Point;

	import tree.command.Actor;
	import tree.command.Command;
	import tree.common.Config;
	import tree.common.Config;
	import tree.model.GenNode;
	import tree.model.Generation;
	import tree.model.Generation;
	import tree.model.Join;
	import tree.model.Join;
	import tree.model.JoinType;
	import tree.model.Node;
	import tree.model.Person;
	import tree.signal.ModelSignal;
	import tree.signal.ViewSignal;
	import tree.view.canvas.JoinLine;
	import tree.view.canvas.NodeIcon;

	public class CanvasController extends Actor{

		private var canvas:Canvas;

		public function CanvasController(canvas:Canvas) {
			this.canvas = canvas;
			detain();

			canvas.out.add(onCanvasDeselect);
			canvas.click.add(onCanvasDeselect);
		}

		public function drawJoin(g:GenNode):void {
			var n:NodeIcon = canvas.getNodeIcon(g.node.uid);
			if(!n){
				n = canvas.getNodeIconAndCreate(g);
				n.complete.addOnce(onNodeCompleteOnce);
				n.click.add(onNodeClicked);
				n.rollUnrollClick.add(onNodeRolUnrollClicked);
				n.deleteClick.add(onNodeDeleteClicked);
				n.over.add(onNodeOver);
				n.out.add(onNodeOut);
				n.showArrowMenu.add(onShowArrowMenu);
				n.hideArrowMenu.add(onHideArrowMenu);
			}

			if(g.join.from){
				n.refreshPosition(false);
				n.hide(false);

				var l:JoinLine = canvas.getJoinLineAndCreate(g.join.from.uid, g.node.uid);
				l.data = g.join;
				l.complete.addOnce(onLineShowedOnce);
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

		public function removeJoin(g:GenNode):void{
			var n:NodeIcon = canvas.getNodeIcon(g.node.uid);
			n.complete.addOnce(onNodeHidedOnce);
			n.hide();

			var l:JoinLine = canvas.getJoinLine(g.join.from.uid, g.node.uid);
			l.hide();
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
				var l:JoinLine = canvas.getJoinLine(j.from.uid, j.uid);
				if(l)
					l.hide();
			}

			n.complete.addOnce(onNodeIconPositionChanged);
			n.refreshPosition();
		}

		private function onNodeIconPositionChanged(node:NodeIcon):void{
			if(node.data)// когда пока играла анимация, эту ноду уже удалили (ручноая анимация по "N")
				refreshNodeJoinLines(node.data.node);
		}

		private function onLineShowedOnce(line:JoinLine):void {
			var j:Join = line.data;
			var n:NodeIcon = canvas.getNodeIcon(j.associate.uid);
			n.show();
		}

		private function onNodeHidedOnce(n:NodeIcon):void{
			var line:JoinLine = canvas.getJoinLine(n.data.join.from.uid, n.data.node.uid);
			var node:Node = n.data.node;
			canvas.destroyLine(line);
			canvas.destroyNode(n);
			canvas.fireComplete();

			refreshNodeJoinLines(node);
		}

		private function onNodeCompleteOnce(n:NodeIcon):void {
			refreshNodeJoinLines(n.data.node);
			canvas.fireComplete();
		}

		private function refreshNodeJoinLines(node:Node):void {
			var j:Join;
			var l:JoinLine;

			var linetToRefresh:Array = [];

			for each(j in node.iterator)
			{
				l = canvas.getJoinLine(j.from.uid, j.uid);
				if(l)
					linetToRefresh.push(l);
			}

			// если рассматриваемая нода имеет супруга, обновить джоин-лайны детей
			var m:Person = node.marry;
			if(m && m.node.visible){
				for each(j in m.node.iterator)
					if(j.type.superType == JoinType.SUPER_TYPE_BREED){
						l = canvas.getJoinLine(j.from.uid, j.uid);
						if(l && linetToRefresh.indexOf(l) == -1)
							linetToRefresh.push(l)
					}
			}

			for each(l in linetToRefresh){
				l.show();
			}
		}

		private function onGenerationChanged(generation:Generation):void {
			canvas.refreshGenerations();

			// надо обновить ноды текущей generation и всех нижележащих
			for each(var gener:Generation in model.generations.iterator)
				//if(gener.generation <= generation.generation)
					for each(var g:GenNode in gener.iterator)
						onNodePositionChanged(g.node);
		}

		private function onNodeClicked(node:NodeIcon):void{
			bus.dispatch(ViewSignal.PERSON_SELECTED, node.data.node.person);
		}

		private function onNodeRolUnrollClicked(node:NodeIcon):void{
			bus.dispatch(ViewSignal.NODE_ROLL_UNROLL, node.data.node);
		}

		private function onNodeDeleteClicked(node:NodeIcon):void{
			bus.dispatch(ModelSignal, node.data.join);
		}

		public function onNodeOver(node:NodeIcon):void{
			canvas.highlightNode(node);
		}

		public function onNodeOut(node:NodeIcon):void{
			if(canvas.arrowMenu.arrow && canvas.arrowMenu.arrow.data == node.data.node.person)
				return;// если для ноды открыто меню, то не сниаем выделение запросто
			canvas.unhighlightNode(node);
		}

		public function onPersonSelected(person:Person):void {
			canvas.selectNode(person.uid);
		}

		public function centreOn(person:Person = null, animated:Boolean = false):void{
			var x:int = (Config.WIDTH - Config.GUI_WIDTH) * 0.5 - Canvas.ICON_WIDTH * 0.5;
			var y:int = Config.PANEL_HEIGHT + (Config.HEIGHT - Config.PANEL_HEIGHT) * 0.5 - Canvas.ICON_HEIGHT;
			if(person){
				var node:NodeIcon = canvas.getNodeIcon(person.uid);
				if(node){
					x -= node.x * model.zoom;
					y -= node.y * model.zoom;
				}
			}
			if(animated){
				GTweener.to(canvas, 0.3, {x:x, y:y});
			}else{
				canvas.x = x;
				canvas.y = y;
			}
			canvas.setSize(Config.WIDTH - Config.GUI_WIDTH, Config.HEIGHT - Config.PANEL_HEIGHT);
		}

		private function onShowArrowMenu(arrow:NodeArrow):void{
			canvas.arrowMenu.show(arrow);
		}

		private function onHideArrowMenu():void{
			canvas.arrowMenu.hide()
		}

		public function onCanvasDeselect(c:Canvas = null):void{
			if(canvas.highlightedNode)
				canvas.unhighlightNode(canvas.highlightedNode);
			canvas.arrowMenu.hide()
		}

		public function onCanvasDragged():void{
			if(!canvas.arrowMenu.visible)
				return;

			canvas.arrowMenu.refreshPosition();
		}
	}
}
