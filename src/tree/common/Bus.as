package tree.common {
	import com.junkbyte.console.Cc;

	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.FullScreenEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;

	import org.osflash.signals.IPrioritySignal;

	import org.osflash.signals.ISignal;
	import org.osflash.signals.PrioritySignal;
	import org.osflash.signals.Signal;

	import tree.Tree;
	import tree.model.Model;
	import tree.signal.DragSignal;

	public class Bus extends NamedSignal{

		public var sceneResize:IPrioritySignal;// callback(point:Point)
		private var tmpPoint:Point;


		/**
		 * Надо показать или скрыть лоадер. Передаются проценты загрузки  0..1,
		 * <нет аргумента>    - если надо скрыть
		 * <= 0 - если не надо показывать прогресс
		 */
		public var loaderProgress:IPrioritySignal;// callback(progress:Number)
		public var initialLoadingProgress:IPrioritySignal;// callback(step:int, progress:Number)

		public var mouseWheel:IPrioritySignal;// callback(delta:int)

		public var drag:IPrioritySignal;// callback(dragSignal:DragSignal)
		public var startDrag:IPrioritySignal;// callback(dragSignal:DragSignal)
		public var stopDrag:IPrioritySignal;// callback(dragSignal:DragSignal)
		private var dragSignal:DragSignal;

		public var mouseDown:IPrioritySignal;// callback(position:Point)

		public var mouseUp:IPrioritySignal;// callback(position:Point)

		public var mouseMove:IPrioritySignal;// callback(position:Point)

		public var zoom:IPrioritySignal// callback(zoom:Number)

		public var fullscreen:IPrioritySignal;

		private var stage:Stage;

		public var treeViewConstructed:ISignal;
		public var constructionInProcess:ISignal;

		public var guiChanged:ISignal;// callback(open:Boolean)

		public function Bus(stage:Stage) {
			super(null, '');
			this.stage = stage;

			sceneResize = new BusSignal(this, 'sceneResize', Point);
			tmpPoint = new Point(stage.stageWidth, stage.stageHeight);
			stage.addEventListener(Event.RESIZE, onResize);

			loaderProgress = new BusSignal(this, 'loaderProgress');
			initialLoadingProgress = new BusSignal(this, 'initialLoadingProgress');

			mouseWheel = new BusSignal(this, 'mouseWheel');
			stage.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);

			mouseDown = new BusSignal(this, 'mouseDown');
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);

			mouseUp = new BusSignal(this, 'mouseUp');
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			stage.addEventListener(Event.MOUSE_LEAVE, onMouseUp);

			mouseMove = new BusSignal(this, 'mouseMove');
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);

			drag = new BusSignal(this, 'drag');
			startDrag = new BusSignal(this, 'startDrag');
			stopDrag = new BusSignal(this, 'stopDrag');
			dragSignal = new DragSignal();
			mouseDown.addWithPriority(onStartDrag, int.MIN_VALUE + 1000);
			mouseUp.addWithPriority(onStopDrag, int.MIN_VALUE + 1000);

			zoom = new BusSignal(this, 'zoom');

			fullscreen = new BusSignal(this, 'fullscreen');
			stage.addEventListener(FullScreenEvent.FULL_SCREEN, onFullScreenChanged);

			treeViewConstructed = new Signal();
			constructionInProcess = new Signal();

			guiChanged = new Signal();
		}

		public function onResize(event:Event):void {
			if(event == null || event.target == stage){
				tmpPoint.x = Config.WIDTH = stage.stageWidth;
				tmpPoint.y = Config.HEIGHT = stage.stageHeight;
				sceneResize.dispatch(tmpPoint);
			}
		}

		private function onMouseWheel(event:MouseEvent):void {
			if(Tree.instance.mouseOnCanvas()){
				CONFIG::debug {
					if(Cc.visible)
						return;
				}
				mouseWheel.dispatch(event.delta);
			}
		}

		private function onMouseDown(event:MouseEvent):void {
			if(Tree.instance.mouseOnCanvas()){
				tmpPoint.x =  Tree.instance.mouseX;
				tmpPoint.y =  Tree.instance.mouseY;
				mouseDown.dispatch(tmpPoint);
			}
		}

		private function onMouseUp(event:Event):void {
			tmpPoint.x =  Tree.instance.mouseX;
			tmpPoint.y =  Tree.instance.mouseY;
			mouseUp.dispatch(tmpPoint);
		}

		private function onMouseMove(event:MouseEvent):void {
			if(Tree.instance.mouseOnCanvas()){
				tmpPoint.x =  Tree.instance.mouseX;
				tmpPoint.y =  Tree.instance.mouseY;
				mouseMove.dispatch(tmpPoint);
			}
		}

		private function onStartDrag(pos:Point):void {
			dragSignal.lastPoint.x = dragSignal.startPoint.x = pos.x;
			dragSignal.lastPoint.y = dragSignal.startPoint.y = pos.y;
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onDragMove);
			startDrag.dispatch(dragSignal);
		}

		private function onStopDrag(pos:Point):void {
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onDragMove);
			stopDrag.dispatch(dragSignal);
		}

		private function onDragMove(event:MouseEvent):void {
			dragSignal.currentPoint.x = Tree.instance.mouseX;
			dragSignal.currentPoint.y =  Tree.instance.mouseY;

			dragSignal.totalDelta.x = dragSignal.startPoint.x - dragSignal.currentPoint.x;
			dragSignal.totalDelta.y = dragSignal.startPoint.y - dragSignal.currentPoint.y;

			dragSignal.delta.x = dragSignal.currentPoint.x - dragSignal.lastPoint.x;
			dragSignal.delta.y = dragSignal.currentPoint.y - dragSignal.lastPoint.y;

			drag.dispatch(dragSignal);

			dragSignal.lastPoint.x = dragSignal.currentPoint.x;
			dragSignal.lastPoint.y = dragSignal.currentPoint.y;
		}

		private function onFullScreenChanged(event:FullScreenEvent):void{
			fullscreen.dispatch(event.fullScreen)
			onResize(null);
		}
	}
}

import com.junkbyte.console.Cc;

import org.osflash.signals.ISignal;
import org.osflash.signals.PrioritySignal;


class BusSignal extends PrioritySignal
{
	private var name:String;
	private var bus:ISignal;

	public function BusSignal(bus:ISignal, name:String, ...classes)
	{
		this.name = name;
		this.bus = bus;
		super(classes);
	}

	override public function dispatch(... valueObjects):void {
		//Cc.log("DISPATCH: (" + name + ")" + valueObjects);
		super.dispatch.apply(null, valueObjects)
	}
}