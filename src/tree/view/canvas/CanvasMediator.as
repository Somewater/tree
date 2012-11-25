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
	import tree.view.Tweener;

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
			bus.sceneResize.add(onResize);
			bus.addNamed(ViewSignal.NEED_CENTRE_CANVAS, onNeedCentreCanvas)
		}

		override public function clear():void {
			super.clear();
			canvas = null;
		}

		override protected function refresh():void {
		}

		private function onResize(size:Point):void{
			canvas.setSize(model.contentWidth, Config.HEIGHT - Config.PANEL_HEIGHT);
		}

		private function onModelChanged():void {
			// todo: провести анимацию перехода, если уже было построено какое-то дерево
			controller.centreOn();
			model.treeViewConstructed = false;
			model.constructionInProcess = true;
			model.zoom = model.options.defaultZoom;
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
			zoomTween = Tweener.to(view, 0.2, {x : centreX, y : centreY, scaleX : zoom, scaleY : zoom}, {onComplete: onZoomCompleted});

			controller.onCanvasDeselect();
		}

		private function onZoomCompleted(g:GTween = null):void{
			canvas.refreshNodesVisibility(true);
			controller.align();
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
			canvas.refreshNodesVisibility();
		}

		private function onStopDrag(signal:DragSignal):void{
			controller.align();
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