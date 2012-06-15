package menu {
	
	import family.DragController;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class CreateTreeSetter extends Sprite implements IUse,IDisposable {
		
		private var _menu:Menu;
		private var _createTree:CreateTree = new CreateTree();
		private var _dragController:DragController;
		
		public function CreateTreeSetter(menu:Menu) {
			_menu = menu;
		}
		
		private function onMouseDown(e:MouseEvent):void {
			_dragController = new DragController(ConsecutiveFamilyTree.instance.stage, this);
			_dragController.addEventListener(DragController.STOP_DRAG_EVENT, onStopDrag);
			_dragController.init();
		}
		
		private function onStopDrag(e:Event):void {
			_dragController.removeEventListener(DragController.STOP_DRAG_EVENT, onStopDrag);
			_dragController = null;
		}
		
		/** Интерфейс */
		
		public function init():void {
			_createTree.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			_createTree.buttonMode = true;
			addChild(_createTree);
		}
		
		public function update():void {
			
		}
		
		public function dispose():void {
			_createTree.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			_dragController.removeEventListener(DragController.STOP_DRAG_EVENT, onStopDrag);
			_dragController.dispose();
		}
	}
}
