package commands.menu {
	
	import commands.ICommand;
	
	import family.tree.control.TreeController;

	public class ChangeTreeSortTypeCommand implements ICommand {
		
		private var _type:uint;
		
		public function ChangeTreeSortTypeCommand(type:uint) {
			_type = type;
		}
		
		/** Интерфейс */
		
		public function execute():void {
			TreeController.auto = _type;
			TreeController.instance.changeSortType();
		}
	}
}