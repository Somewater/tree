package commands.menu {
	
	import commands.ICommand;
	
	import family.tree.control.TreeController;
	
	public class ChangeTreeRelateDrawTypeCommand implements ICommand {
		
		private var _type:uint;
		
		public function ChangeTreeRelateDrawTypeCommand(type:uint) {
			_type = type;
		}
		
		/** Интерфейс */
		
		public function execute():void {
			TreeController.instance.changeRelateDrawType(_type);
		}
	}
}