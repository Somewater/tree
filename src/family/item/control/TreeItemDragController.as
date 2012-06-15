package family.item.control {
	
	import family.desktop.Desktop;
	import family.level.Level;
	import family.relation.Union;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import family.item.TreeItem;
	
	public class TreeItemDragController extends EventDispatcher implements IUpdate,IDisposable {
		
		public static const STOP_DRAG_EVENT:String = "StopDragEvent";
		
		private var _treeItem:TreeItem;
		private var _union:Union;
		
		private var _oldPos:Point;
		private var _dp:Point;
		
		public function TreeItemDragController(treeItem:TreeItem, union:Union) {
			_treeItem = treeItem;
			_union = union;
		}
		
		public function get treeItem():TreeItem { return _treeItem; }
		public function get union():Union { return _union; }
		
		private function onMouseMove(e:MouseEvent):void {
			_treeItem.tree.positionController.lightLevelCell(this);
			_treeItem.tree.renew();
			
			if (_union) { // Таскаем за TreeItem все его UnionTreeItems...
				var newPos:Point = new Point(_treeItem.x, _treeItem.y);
				_dp = new Point(_oldPos.x, _oldPos.y).subtract(newPos);
				var treeItem:TreeItem;
				for (var i:uint = 0; i < _union.unions.length; i++) {
					treeItem = _union.unions[i];
					treeItem.x = treeItem.x - _dp.x;
					treeItem.y = treeItem.y - _dp.y;
				}
				_oldPos = newPos;
			}
		}
		
		private function onDragStop(e:MouseEvent):void {
			_treeItem.tree.positionController.lightLevelCell(this);
			_treeItem.tree.positionController.stopDrag();
			
			dispose();
			dispatchEvent(new Event(STOP_DRAG_EVENT));
		}	
		
		/** Интрефейс */
		
		public function init():void {
			// Получаю TreeLevel...
			var desktopLevel:Level = Desktop.instance.getLevelByUID(_treeItem.level);
			var rect:Rectangle = new Rectangle(
				-Desktop.instance.desktopInfo.halfSize,
				desktopLevel.y,
				desktopLevel.width,
				desktopLevel.height - _treeItem.height
			);
			
			ConsecutiveFamilyTree.instance.stage.addEventListener(MouseEvent.MOUSE_UP, onDragStop);
			ConsecutiveFamilyTree.instance.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			_treeItem.tree.addChild(_treeItem);
			
			_oldPos = new Point(_treeItem.x, _treeItem.y);
			
			_treeItem.startDrag(false, rect);
		}
		
		public function update():void {
			
		}
		
		public function dispose():void {
			_treeItem.stopDrag();
			
			ConsecutiveFamilyTree.instance.stage.removeEventListener(MouseEvent.MOUSE_UP, onDragStop);
			ConsecutiveFamilyTree.instance.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		}
	}
}