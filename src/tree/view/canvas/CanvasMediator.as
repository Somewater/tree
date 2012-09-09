package tree.view.canvas {

	import com.gskinner.motion.GTween;
	import com.gskinner.motion.GTweener;

	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	import tree.command.view.CompleteTreeDraw;

	import tree.common.Config;
	import tree.model.GenNode;
	import tree.model.Generation;
	import tree.model.Join;
	import tree.model.Node;
	import tree.model.Person;
	import tree.signal.DragSignal;
	import tree.signal.ModelSignal;
	import tree.signal.ViewSignal;
	import tree.view.Mediator;

	public class CanvasMediator extends Mediator
	{
		private var canvas:Canvas;
		private var controller:CanvasController;
		private var tmpPoint:Point = new Point();
		private var zoomTween:GTween;

		public function CanvasMediator(view:Canvas, controller:CanvasController)
		{
			this.canvas = view;
			this.controller = controller;
			canvas.addEventListener(Event.COMPLETE, onCanvasComplete);
			super(view);

			addModelListener(ModelSignal.NODES_RECALCULATED, onModelChanged);
			addModelListener(ViewSignal.DRAW_JOIN, onNeedDrawJoin);
			addModelListener(ViewSignal.REMOVE_JOIN, onNeedRemoveJoin);
			addModelListener(ViewSignal.PERSON_SELECTED, onPersonSelected);
			addModelListener(ViewSignal.PERSON_CENTERED, onPersonCentered);
			bus.zoom.add(onZoom);
			bus.mouseWheel.add(onMouseWheel);
			bus.drag.add(onDrag);
			bus.stopDrag.add(onStopDrag);
			bus.addNamed(ViewSignal.NEED_CENTRE_CANVAS, onNeedCentreCanvas)
		}

		override public function clear():void {
			super.clear();
			canvas = null;
		}

		override protected function refresh():void {
			controller.centreOn();
		}

		private function onModelChanged():void {
			// todo: провести анимацию перехода, если уже было построено какое-то дерево
			controller.centreOn();
			model.treeViewConstructed = false;
			model.constructionInProcess = true;
			bus.dispatch(ViewSignal.CANVAS_READY_FOR_START);
		}

		private function onNeedDrawJoin(g:GenNode):void {
			controller.drawJoin(g);
		}

		private function onNeedRemoveJoin(g:GenNode):void {
			controller.removeJoin(g);
		}

		private function onZoom(zoom:Number):void {
			var currentZoom:Number = view.scaleX;

			var zoomCenterRelativeCanvasX:Number = (model.zoomCenter.x) * zoom;
			var zoomCenterRelativeCanvasY:Number = (model.zoomCenter.y) * zoom;

			var centreX:Number = view.x + model.zoomCenter.x * (currentZoom - zoom);
			var centreY:Number = view.y + model.zoomCenter.y * (currentZoom - zoom);

			if(zoomTween)GTweener.remove(zoomTween);
			zoomTween = GTweener.to(view, 0.2, {x : centreX, y : centreY, scaleX : zoom, scaleY : zoom});

			controller.onCanvasDeselect();
		}

		private function onMouseWheel(delta:int):void {
			// только +-1
			delta = delta > 0 ? 1 : -1;

			tmpPoint.x = canvas.mouseX;
			tmpPoint.y = canvas.mouseY;
			//var p:Point = canvas.localToGlobal(tmpPoint);
			model.zoomCenter.x = tmpPoint.x;
			model.zoomCenter.y = tmpPoint.y;
			model.zoom = Math.max(0.1, Math.min(1, model.zoom + delta * 0.2));
			controller.onCanvasDeselect();
		}

		private function onDrag(signal:DragSignal):void {
			canvas.x += signal.delta.x;
			canvas.y += signal.delta.y;
			controller.onCanvasDragged();
		}

		private function onStopDrag(signal:DragSignal):void{
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
			screen.x = -view.x;
			screen.y = -view.y + Config.PANEL_HEIGHT;
			screen.right = screen.x + Config.WIDTH - Config.GUI_WIDTH;
			screen.bottom = screen.y + Config.HEIGHT - Config.PANEL_HEIGHT;

			var centreX:Number = NaN;
			var centreY:Number = NaN;

			if(screen.right < rect.x)
				centreX = rect.x - Config.WIDTH + Config.GUI_WIDTH;
			else if(screen.x > rect.right)
				centreX = rect.right;

			if(screen.bottom < rect.y)
				centreY = rect.y - Config.HEIGHT + Config.PANEL_HEIGHT;
			else if(screen.y > rect.bottom)
				centreY = rect.bottom;

			var obj:Object = {};
			if(!isNaN(centreX)) obj['x'] = -centreX;
			if(!isNaN(centreY)) obj['y'] = Config.PANEL_HEIGHT - centreY;
			if(!isNaN(centreX) || !isNaN(centreY))
				GTweener.to(view, 0.3, obj);
		}

		private function onCanvasComplete(event:Event):void {
			bus.dispatch(ViewSignal.JOIN_DRAWED);
		}

		private function onPersonSelected(person:Person):void{
			controller.onPersonSelected(person);
		}

		private function onPersonCentered(person:Person):void{
			controller.centreOn(person, true);
		}

		private function onNeedCentreCanvas():void {
			controller.centreOn(null, true);
		}
	}
}

	class Rect{
			public var x:Number = 0;
	public var y:Number = 0;
	public var right:Number = 0;
	public var bottom:Number = 0;
}