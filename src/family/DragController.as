package family {
	
	import family.level.Level;
	import family.level.LevelCell;
	import family.tree.Tree;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import layers.control.LayerController;
	
	import utils.Utils;
	
	public class DragController extends EventDispatcher implements IUpdate,IDisposable {
		
		public static const STOP_DRAG_EVENT:String = "StopDragEvent";
		
		private static const ALPHA:Number = .3;
		
		private var _stage:Stage;
		private var _object:DisplayObjectContainer;
		private var _dropTarget:Object;
		private var _foto:Sprite;
		
		private var _dropTargetLevel:Level;
		private var _dropTargetLevelCell:LevelCell;
		
		public function DragController(stage:Stage, object:DisplayObjectContainer) {
			_stage = stage;
			_object = object;
		}
		
		public function get object():Object { return _object; }
		
		public function get dropTargetLevel():Level { return _dropTargetLevel; }
		public function get dropTargetLevelCell():LevelCell { return _dropTargetLevelCell; }
		
		private function onMouseUp(e:MouseEvent):void {
			remove();
			_foto.stopDrag();
			trySetDropTargets();
			
			if (_dropTargetLevel) _dropTargetLevel.unLight();
			if (_dropTargetLevelCell) _dropTargetLevelCell.unLight();
			
			dispatchEvent(new Event(STOP_DRAG_EVENT));
		}
		
		private function onMouseLeave(e:Event):void {
			remove();
			_foto.stopDrag();
			
			if (_dropTargetLevel) _dropTargetLevel.filters = null;
			if (_dropTargetLevelCell) _dropTargetLevelCell.filters = null;
			
			dispatchEvent(new Event(STOP_DRAG_EVENT));
		}
		
		private function remove():void {
			try {
				_foto.parent.removeChild(_foto);
			} catch (e:Error) {
				
			}
			_stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			_stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			_stage.removeEventListener(Event.MOUSE_LEAVE, onMouseLeave);
		}
		
		private function onMouseMove(e:MouseEvent):void {
			trySetDropTargets();
		}
		
		private function trySetDropTargets():void {
			if (_dropTargetLevel) _dropTargetLevel.unLight();
			if (_dropTargetLevelCell) _dropTargetLevelCell.unLight();
			
			_dropTargetLevel = null;
			_dropTargetLevelCell = null;
			
			_dropTarget = _foto.dropTarget;
			
			try {
				_dropTargetLevel = Level(_dropTarget);
			} catch (e:Error) {
				
			}
			
			try {
				_dropTargetLevelCell = LevelCell(_dropTarget);
			} catch (e:Error) {
				
			}
			
			if (_dropTargetLevel) _dropTargetLevel.light()
			if (_dropTargetLevelCell) _dropTargetLevelCell.light();
		}
		
		/** Интрефейс */
		
		public function init():void {
			var bound:Rectangle = _object.getBounds(_object);
			var bitmapData:BitmapData = new BitmapData(_object.width, _object.height, true, 0x00000000);
			var matrix:Matrix = new Matrix();
			matrix.translate(-bound.x, -bound.y);
			bitmapData.draw(_object, matrix, null, null, null, true);
			var bitmap:Bitmap = new Bitmap(bitmapData);
			
			bitmap.alpha = ALPHA;
			
			_foto = new Sprite();
			_foto.addChild(bitmap);
			_foto.mouseChildren = false;
			
			LayerController.instance.addToTreeLayer(_foto);
			
			_foto.startDrag(true);
			
			_stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			_stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			_stage.addEventListener(Event.MOUSE_LEAVE, onMouseLeave);
		}
		
		public function update():void {
			
		}
		
		public function dispose():void {
			remove();
			
			_stage = null;
			_object = null;
			_foto = null;
		}
	}
}