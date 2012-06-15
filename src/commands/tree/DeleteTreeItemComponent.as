package commands.tree {
	
	import commands.ICommand;
	
	import family.tree.Tree;
	import family.item.TreeItem;
	
	public class DeleteTreeItemComponent implements ICommand {
		
		private var _receiver:Tree;
		private var _treeItem:TreeItem;
		
		public function DeleteTreeItemComponent(receiver:Tree, treeItem:TreeItem) {
			_receiver = receiver;
			_treeItem = treeItem;
		}
		
		/** Интерфейс */
		
		public function execute():void {
			
		}
	}
}