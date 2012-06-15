package family.tree {
	import family.tree.control.TreeController;
	
	
	public class TreeInfo {
		
		public var treeController:TreeController;
		public var xml:XML;
		
		public function TreeInfo(
			treeController:TreeController,
			xml:XML		
		) {
			this.treeController = treeController;
			this.xml = xml;
		}
	}
}