package tree.view.canvas {

	import flash.events.Event;
	import flash.geom.Point;

	import tree.common.Config;
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
		private var zoomCenter:Point = new Point();
		private var tmpPoint:Point = new Point();

		public function CanvasMediator(view:Canvas)
		{
			this.canvas = view;
			canvas.addEventListener(Event.COMPLETE, onCanvasComplete);
			super(view);

			addModelListener(ModelSignal.NODES_RECALCULATED, onModelChanged);
			addModelListener(ViewSignal.DRAW_JOIN, onNeedDrawJoin);
			bus.zoom.add(onZoom);
			bus.mouseWheel.add(onMouseWheel);
			bus.drag.add(onDrag);
		}

		override public function clear():void {
			super.clear();
			canvas = null;
		}

		override protected function refresh():void {
			canvas.x = (Config.WIDTH - Config.GUI_WIDTH) * 0.5;
			canvas.y = Config.HEIGHT * 0.5;
			canvas.setSize(Config.WIDTH - Config.GUI_WIDTH, Config.HEIGHT);
		}

		private function onModelChanged():void {
			// todo: провести анимацию перехода, если уже было построено какое-то дерево

			bus.dispatch(ViewSignal.CANVAS_READY_FOR_START);
		}

		private function onNeedDrawJoin(join:Join,
										node:Node,
										person:Person,
										sourceNode:Node,
										sourcePerson:Person):void {
			canvas.drawJoin(join, node);
		}

		private function onZoom(zoom:Number):void {
			var currentZoom:Number = view.scaleX;

			var zoomCenterRelativeCanvasX:Number = (zoomCenter.x) * zoom;
			var zoomCenterRelativeCanvasY:Number = (zoomCenter.y) * zoom;

			view.scaleX = zoom;
			view.scaleY = zoom;

			view.x += zoomCenter.x * (currentZoom - zoom);
			view.y += zoomCenter.y * (currentZoom - zoom);
		}

		private function onMouseWheel(delta:int):void {
			tmpPoint.x = canvas.mouseX;
			tmpPoint.y = canvas.mouseY;
			//var p:Point = canvas.localToGlobal(tmpPoint);
			zoomCenter.x = tmpPoint.x;
			zoomCenter.y = tmpPoint.y;
			model.zoom = Math.max(0.1, Math.min(1, model.zoom - delta * 0.1));
		}

		private function onDrag(signal:DragSignal):void {
			canvas.x += signal.delta.x;
			canvas.y += signal.delta.y;
		}

		private function onCanvasComplete(event:Event):void {
			bus.dispatch(ViewSignal.JOIN_DRAWED);
		}
	}
}
