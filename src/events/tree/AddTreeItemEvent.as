package events.tree {
	
	import family.item.TreeItem;
	
	import flash.events.Event;
	
	public class AddTreeItemEvent extends Event {
		
		public static const ADD_TREE_ITEM_EVENT:String = "AddTreeItemEvent";
		
		private var _treeItem:TreeItem;
		
		public function AddTreeItemEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, component:TreeItem = null) {
			_treeItem = treeItem;
			super(type, bubbles, cancelable);
		}
		
		public function get treeItem():TreeItem { return _treeItem; }
		
		public override function clone():Event {			
			return new AddTreeItemEvent(type, bubbles, cancelable, _treeItem);
		}
	}
}