package layers.control {
	
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import utils.Tweens;
	import utils.Utils;
	
	public class TransformController extends EventDispatcher implements IDisposable {
		
		private static const SHOW_POINT_TWEEN_TYPE:String = "easeOutCubic";
		private static const SHOW_POINT_TWEEN_TIME:Number = 1;
		
		private var _stage:Stage;
		private var _wheelInfo:WheelInfo;
		private var _layer:Object;
		private var _dragTarget:Object;
		
		public function TransformController(
			stage:Stage,
			layer:Object, // Что двигать или скейлить...
			dragTarget:Object, // За что хвататься...
			wheelInfo:WheelInfo = null
		) {
			_stage = stage;
			_layer = layer;
			_dragTarget = dragTarget;
			_wheelInfo = wheelInfo;
		}
		
		public function start():void {
			_dragTarget.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			_stage.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWeel);
			_stage.addEventListener(Event.MOUSE_LEAVE, onMouseLeave);
		}
		
		public function showPoint(point:Point):void {
			LayerController.instance.lockStage();
			
			var t:Point = _layer.localToGlobal(point);
			
			var resPoint:Point = new Point();
			
			resPoint.x = _layer.x - t.x;
			resPoint.y = _layer.y - t.y;
			
			Utils.addOnFrame(renew);
			
			Tweens.tween(
				_layer,
				SHOW_POINT_TWEEN_TYPE,
				SHOW_POINT_TWEEN_TIME,
				new Point(_layer.x, _layer.y),
				new Point(_layer.scaleX, _layer.scaleY),
				1,
				new Point(1, 1),
				resPoint,
				new Point(_layer.scaleX, _layer.scaleY),
				1,
				new Point(1, 1),
				finish
			);
		}
		
		private function renew():void {
			onMouseMove(null);
		}
		
		private function finish(ds:DisplayObject):void {
			Utils.removeOnFrame(renew);
			LayerController.instance.unlockStage();
			renew();
		}
				
		private function onMouseWeel(e:MouseEvent):void {
			var delta:Number = e.delta;
			var target:Object = _wheelInfo.target;
			
			var g:Point = new Point(_stage.mouseX, _stage.mouseY);
			var l:Point = target.globalToLocal(g);
			
			target.scaleX = target.scaleY = target.scaleX += delta / _wheelInfo.k;
			if (target.scaleX < _wheelInfo.min) target.scaleX = target.scaleY = _wheelInfo.min;
			if (target.scaleX > _wheelInfo.max) target.scaleX = target.scaleY = _wheelInfo.max;	
			
			var t:Point = target.localToGlobal(l);
			var ds:Point = g.subtract(t);
			
			target.x = target.x + ds.x;
			target.y = target.y + ds.y;
			
			_stage.dispatchEvent(new Event(Event.RESIZE));
		}
		
		private function onMouseDown(e:MouseEvent):void {
			_dragTarget.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			_stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			_layer.startDrag(false);
		}
		
		private function onMouseUp(e:MouseEvent):void {
			_layer.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			_stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			_layer.stopDrag();
			_stage.dispatchEvent(new Event(Event.RESIZE));
		}
		
		private function onMouseLeave(e:Event):void {
			onMouseUp(null);
		}
		
		private function onMouseMove(e:MouseEvent):void {
			_stage.dispatchEvent(new Event(Event.RESIZE));
		}
		
		/** Интерфейс */
		
		public function dispose():void {
			_dragTarget.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			_stage.removeEventListener(MouseEvent.MOUSE_WHEEL, onMouseWeel);
			_stage.removeEventListener(Event.MOUSE_LEAVE, onMouseLeave);
			_stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			onMouseUp(null);
		}
	}
}