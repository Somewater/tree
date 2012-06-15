package events.tree {
	
	import family.item.TreeItem;
	
	import flash.events.Event;
	
	public class DeleteTreeItemEvent extends Event {
		
		public static const DELETE_TREE_ITEM_EVENT:String = "DeleteTreeItemEvent";
		
		private var _treeItem:TreeItem;
		
		public function DeleteTreeItemEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, treeItem:TreeItem = null) {
			_treeItem = treeItem;
			super(type, bubbles, cancelable);
		}
		
		public function get treeItem():TreeItem { return _treeItem; }
		
		public override function clone():Event {			
			return new DeleteTreeItemEvent(type, bubbles, cancelable, _treeItem);
		}
	}
}