package tree.view.canvas {
	import com.gskinner.motion.GTween;
	import com.gskinner.motion.GTweener;

	import flash.events.Event;
	import flash.geom.Point;

	import tree.command.Actor;
	import tree.command.Command;
import tree.command.RemovePerson;
import tree.common.Config;
	import tree.common.Config;
	import tree.model.GenNode;
	import tree.model.Generation;
	import tree.model.Generation;
	import tree.model.Join;
	import tree.model.Join;
	import tree.model.JoinType;
	import tree.model.Model;
	import tree.model.Node;
	import tree.model.Person;
	import tree.signal.ModelSignal;
	import tree.signal.ViewSignal;
import tree.view.Tweener;
import tree.view.canvas.JoinLine;
	import tree.view.canvas.NodeIcon;
import tree.view.window.MessageWindow;

public class CanvasController extends Actor{

		private var canvas:Canvas;
		private var lineController:LineHighlightController;

		public function CanvasController(canvas:Canvas) {
			this.canvas = canvas;
			this.lineController = new LineHighlightController(canvas);
			detain();

			canvas.out.add(onCanvasDeselect);
			canvas.click.add(onCanvasDeselect);
			canvas.arrowMenu.visible = false;
			canvas.arrowMenu.actionClick.add(onAddNewPersonClick)
			canvas.arrowMenu.menuHided.add(onHideArrowMenuFromMenu)
			canvas.arrowMenu.editPersonClick.add(onPersonEditClick);
			canvas.arrowMenu.addPhotoClick.add(onAddPhotoEditClick);
			canvas.arrowMenu.deletePersonClick.add(onDeletePersonEditClick);
			bus.constructionInProcess.add(onConstructionStatusChanged);
			bus.addNamed(ViewSignal.REFRESH_NODE_POSITIONS, refreshAllNodePositions);
			bus.addNamed(ViewSignal.REFRESH_JOIN_LINES, refreshAllJoinLines);
			bus.addNamed(ViewSignal.REFRESH_GENERATIONS, refreshAllGenerations);
			bus.addNamed(ViewSignal.REDRAW_JOIN_LINES, refreshPersonJoinLines);
			bus.addNamed(ViewSignal.PERSON_HIGHLIGHTED, onPersonHighlighted);
		}

		public function drawJoin(g:GenNode):void {
			var n:NodeIcon = canvas.getNodeIcon(g.node.uid);
			if(!n){
				n = canvas.getNodeIconAndCreate(g);
				n.complete.addOnce(onNodeCompleteOnce);
				n.click.add(onNodeClicked);
				n.dblClick.add(onNodeBldClicked);
				n.rollUnrollClick.add(onNodeRolUnrollClicked);
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
				if(!l.nodesIsDead())
					l.play()
				else
					onLineShowedOnce(l);
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
			if(l) l.hide();
		}

		private function onNodePositionChanged(node:Node):void {
			// саму иконку поправить
			var n:NodeIcon = canvas.getNodeIcon(node.uid);
			if(!n){
				warn("Attempt refresh position of non existent node " + node);
				return;
			}

			if(!n.positionIsDirty()){
				warn("Position refresh cancelled");
				// обновление координат не требуется
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

		private function refreshPersonJoinLines(person:Person):void{
			refreshNodeJoinLines(person.node);
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
				else if(node.visible && canvas.getNodeIcon(j.uid) != null){
					// надо создать связь (при условии что это важная связь)
					l = canvas.getJoinLineAndCreate(j.from.uid, j.uid);
					l.data = j;
					l.play();
				}
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
				if(l.nodesIsDead()) l.hide()
				else l.show();
			}

			// TODO: удалить ненужные связи типа bro
		}

		private function onGenerationChanged(generation:Generation):void {
			canvas.refreshGenerations();

			// надо обновить ноды текущей generation и всех нижележащих
			var generationNumber:int = generation.generation;
			var des:Boolean = Model.instance.descending;
			for each(var gener:Generation in model.generations.iterator)
				if(des ? (generationNumber < 0 ? gener.generation <= generationNumber : gener.generation >= generationNumber) :
						 (generationNumber > 0 ? gener.generation >= generationNumber : gener.generation <= generationNumber))
					for each(var g:GenNode in gener.iterator){
						onNodePositionChanged(g.node);
					}
		}

		private function onNodeClicked(node:NodeIcon):void{
			bus.dispatch(ViewSignal.PERSON_SELECTED, node.data.node.person);
		}

		private function onNodeBldClicked(node:NodeIcon):void{
			bus.dispatch(ViewSignal.PERSON_SELECTED, node.data.node.person);
			model.guiOpen = true;
		}

		private function onNodeRolUnrollClicked(node:NodeIcon):void{
			if(!model.constructionInProcess && model.treeViewConstructed)
				bus.dispatch(ViewSignal.NODE_ROLL_UNROLL, node.data.node);
		}

		private function onNodeDeleteClicked(node:NodeIcon):void{
			bus.dispatch(ModelSignal, node.data.join);
		}

		public function onNodeOver(node:NodeIcon):void{
			if(!model.constructionInProcess){
				lineController.highlightPersonLines(node.data.node.person);
				lineController.supressMouseMoveAction = true;
				canvas.showActionBtnIfHighlight = true;
				bus.dispatch(ViewSignal.PERSON_HIGHLIGHTED, node.data.node.person)
				canvas.showActionBtnIfHighlight = false;
			}
		}

		public function onNodeOut(node:NodeIcon):void{
			lineController.clearHighlighted();
			lineController.supressMouseMoveAction = false;
			if(canvas.highlightedNode == node)
				bus.dispatch(ViewSignal.PERSON_HIGHLIGHTED, null);
		}

		public function onPersonSelected(person:Person):void {
			canvas.selectNode(person.uid);
		}

		public function centreOn(person:Person = null, animated:Boolean = false):void{
			var x:int = model.contentWidth * 0.5 - Canvas.ICON_WIDTH * 0.5;
			var y:int = Config.PANEL_HEIGHT + (Config.HEIGHT - Config.PANEL_HEIGHT) * 0.5 - Canvas.ICON_HEIGHT;
			if(person){
				var node:NodeIcon = canvas.getNodeIcon(person.uid);
				if(!node) return;
				if(node){
					x -= node.x * model.zoom;
					y -= node.y * model.zoom;
				}
			}
			if(animated){
				Tweener.to(canvas, 0.3, {x:x, y:y}, {onComplete: onCentreOnCompleted, onChange: onChangeForCentre});
			}else{
				canvas.x = x;
				canvas.y = y;
				canvas.refreshNodesVisibility()
			}
		}

		private function onChangeForCentre(g:GTween = null):void{
			onCanvasMove();
		}

		private function onCentreOnCompleted(g:GTween = null):void{
			canvas.refreshNodesVisibility(true);
		}

		private function onShowArrowMenu(node:NodeIcon):void{
			centreOn(node.data.join.associate, true)
			Config.content.addChild(canvas.arrowMenu);
			canvas.arrowMenu.visible = true;
			canvas.arrowMenu.show(node);
		}

		private function onHideArrowMenu():void{
			if(canvas.arrowMenu.parent)
				canvas.arrowMenu.parent.removeChild(canvas.arrowMenu);
			canvas.arrowMenu.visible = false;
			canvas.arrowMenu.hide()
		}

		private function onHideArrowMenuFromMenu(m:ContextMenu):void{
			onHideArrowMenu();
		}

		public function onCanvasDeselect(c:Canvas = null):void{
			if(canvas.highlightedNode)
				canvas.unhighlightNode(canvas.highlightedNode);
			//canvas.arrowMenu.hide()
		}

		public function onCanvasDragged():void{
			onCanvasMove();
		}

		private function onConstructionStatusChanged():void{
			if(!model.constructionInProcess){
				// закончено строительство или анимирование нод
				lineController.start();
			}else{
				// ноды в процессе построения или анимации
				lineController.stop();
			}
		}

		private function onAddNewPersonClick(from:Person, joinType:JoinType):void{
			bus.dispatch(ViewSignal.START_EDIT_PERSON, null, joinType, from);
		}

		public function align():void{
			var rect:Rect = new Rect();
			for each(var node:NodeIcon in canvas.iterator){
				if(!node)
					continue;
				var x:int = node.x;
				var y:int = node.y;
				if(x < rect.x)
					rect.x = x;
				else if(x > rect.right)
					rect.right = x;
				if(y < rect.y)
					rect.y = y;
				else if(y > rect.bottom)
					rect.bottom = y;
			}

			var zoom:Number = model.zoom;
			const PADDING_X:int = Canvas.ICON_WIDTH;
			const PADDING_Y:int = Canvas.ICON_HEIGHT;

			rect.right += Canvas.ICON_WIDTH - PADDING_X;
			rect.bottom += Canvas.ICON_HEIGHT - PADDING_Y;
			rect.x += PADDING_X;
			rect.y += PADDING_Y;
			rect.x *= zoom;
			rect.y *= zoom;
			rect.right *= zoom;
			rect.bottom *= zoom;

			var screen:Rect = new Rect();
			screen.x = -canvas.x;
			screen.y = -canvas.y + Config.PANEL_HEIGHT;
			screen.right = screen.x + model.contentWidth;
			screen.bottom = screen.y + Config.HEIGHT - Config.PANEL_HEIGHT;

			var centreX:Number = NaN;
			var centreY:Number = NaN;

			if(screen.right < rect.x)
				centreX = rect.x - model.contentWidth;
			else if(screen.x > rect.right)
				centreX = rect.right;

			if(screen.bottom < rect.y)
				centreY = rect.y - Config.HEIGHT + Config.PANEL_HEIGHT;
			else if(screen.y > rect.bottom)
				centreY = rect.bottom;

			var obj:Object = {};
			if(!isNaN(centreX)) obj['x'] = -centreX;
			if(!isNaN(centreY)) obj['y'] = Config.PANEL_HEIGHT - centreY;
			if(!isNaN(centreX) || !isNaN(centreY)){
				GTweener.to(canvas, 0.3, obj, {onComplete: onStopDragAlignComplete});
			}
		}

		private function onStopDragAlignComplete(g:GTween = null):void{
			canvas.refreshNodesVisibility(true);
		}

		private function refreshAllNodePositions():void{
			canvas.refreshAllNodePositions();
			canvas.refreshNodesVisibility(true);
		}

		private function refreshAllJoinLines():void{
			canvas.refreshAllJoinLines();
		}

		private function refreshAllGenerations():void{
			canvas.refreshGenerations();
		}

		private function onCanvasMove():void{
			if(canvas.arrowMenu.visible)
				canvas.arrowMenu.refreshPosition();
		}

		private function onPersonEditClick(p:Person):void{
			bus.dispatch(ViewSignal.START_EDIT_PERSON, p);
		}

		private function onAddPhotoEditClick(p:Person):void{
			new MessageWindow('TODO: не реализовано').open();
		}

		private function onDeletePersonEditClick(p:Person):void{
			new RemovePerson(p).execute();
		}

		private function onPersonHighlighted(person:Person = null):void{
			canvas.highlightNode(person);
		}
	}
}
class Rect{
			public var x:Number = 0;
	public var y:Number = 0;
	public var right:Number = 0;
	public var bottom:Number = 0;
}
