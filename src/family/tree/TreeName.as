package family.tree {
	
	import family.Automat;
	import family.tree.control.TreeController;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	
	import layers.control.LayerController;
	
	import utils.Utils;
	import family.DragController;
	
	public class TreeName extends Sprite implements IUpdate,IDisposable {
		
		private static const MAIN_COLOR:Number = 0xFF0000;
		private static const COLOR:Number = 0x009900;
		
		private static const BACK_ALPHA:Number = .05;
		private static const BACK_ROUND:uint = 10;
		
		private static const SHIFT:uint = 5;
		
		private var _tree:Tree;
		private var _login:TextField;
		private var _treeDragController:DragController;
		
		public function TreeName(tree:Tree) {
			_tree = tree;
			
			_login = Utils.createTextField(Constants.TREE_NAME_FORMAT);
			
			var color:Number;
			
			if (_tree == TreeController.mainTree) color = MAIN_COLOR;
			else color = COLOR;
			
			_login.textColor = color;
			
			_login.text = _tree.treeInfo.xml.node[0].@name;
			
			addChild(_login);
			
			graphics.beginFill(color, BACK_ALPHA);
			graphics.drawRoundRect(0, 0, width, height, BACK_ROUND, BACK_ROUND);
			graphics.endFill();
			
			addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		}
		
		private function onMouseDown(e:MouseEvent):void {
			_tree.border.reset();
			_treeDragController = new DragController(ConsecutiveFamilyTree.instance.stage, _tree);
			_treeDragController.addEventListener(DragController.STOP_DRAG_EVENT, onStopDrag);
			_treeDragController.init();
		}
		
		private function onStopDrag(e:Event):void {
			_treeDragController.removeEventListener(DragController.STOP_DRAG_EVENT, onStopDrag);
			Automat.instance.tryMoveTree(_treeDragController);
			_treeDragController = null;
		}
		
		public function get login():TextField { return _login; }
		
		/** Интерфейс */
		
		public function update():void {
			var pos:Point = _tree.border.rect.topLeft;
			x = pos.x;
			y = pos.y - height - SHIFT;
		}
		
		public function dispose():void {
			removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			this.parent.removeChild(this);
		}
	}
}