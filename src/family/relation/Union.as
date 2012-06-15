package family.relation {
	
	import family.item.TreeItem;
	
	import flash.display.MovieClip;
	
	public class Union {
		
		private var _parent:TreeItem;
		private var _drawElement:MovieClip;
		private var _unions:Array = [];
		
		public function Union(parent:TreeItem, drawElement:MovieClip = null) {
			_parent = parent;
			_drawElement = drawElement;
		}
		
		public function get unions():Array { return _unions; }
		public function get parent():TreeItem { return _parent; }
		public function get drawElement():MovieClip { return _drawElement; }
		
		public function add(treeItem:TreeItem):void {
			if (_unions.indexOf(treeItem) == -1) {
				_unions.push(treeItem);
				Initializer.instance.log.append("Add to " + _parent.nickname + " the union " + treeItem.nickname + "...");
			}
		}
		
		public function remove(treeItem:TreeItem):void {
			
		}
	}
}