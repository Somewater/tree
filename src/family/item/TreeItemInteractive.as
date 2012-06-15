package family.item {
	
	import events.tree.AddTreeItemEvent;
	import events.tree.DeleteTreeItemEvent;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	public class TreeItemInteractive extends Sprite implements IUse,IDisposable {
		
		private var _treeItem:TreeItem;
		private var _delete:Close = new Close();
		private var _plus:Plus = new Plus();
		//private var _drag:Drag = new Drag();
		
		public function TreeItemInteractive(treeItem:TreeItem) {
			_treeItem = treeItem;
		}
		
		private function onDeleteComponent(e:MouseEvent):void {
			_treeItem.tree.dispatchEvent(
				new DeleteTreeItemEvent(
					DeleteTreeItemEvent.DELETE_TREE_ITEM_EVENT,
					false,
					false,
					_treeItem
				)
			);
		}
		
		private function onAddComponent(e:MouseEvent):void {
			_treeItem.tree.dispatchEvent(
				new AddTreeItemEvent(
					AddTreeItemEvent.ADD_TREE_ITEM_EVENT,
					false,
					false,
					_treeItem
				)
			);
		}
		
		/*private function onMouseDown(e:MouseEvent):void {
			_treeItem.dispatchEvent(e);
		}*/
		
		/** Интерфейс */
		
		public function init():void {
			_delete.x = _treeItem.back.width;
			_delete.addEventListener(MouseEvent.CLICK, onDeleteComponent);
			
			_plus.x = _treeItem.back.width;
			_plus.y = _treeItem.back.height - _plus.height * .5;
			_plus.addEventListener(MouseEvent.CLICK, onAddComponent);
			
			//_drag.x = _treeItem.back.width;
			//_drag.y = _treeItem.back.height - _drag.height;
			//_drag.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			
			_delete.buttonMode = _plus.buttonMode = true;
			
			addChild(_delete);
			addChild(_plus);
			//addChild(_drag);
		}
		
		public function update():void {
			
		}
		
		public function dispose():void {
			_delete.addEventListener(MouseEvent.CLICK, onDeleteComponent);
			_plus.addEventListener(MouseEvent.CLICK, onAddComponent);
			//_drag.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		}
	}
}