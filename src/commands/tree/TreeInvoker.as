package commands.tree {
	
	import commands.ICommand;
	import commands.IInvoker;
	
	import family.tree.Tree;
	
	public class TreeInvoker implements IInvoker,IDisposable {
		
		private var _receiver:Tree;
		private var _currentCommand:ICommand;
		
		public function TreeInvoker(receiver:Tree) {
			_receiver = receiver;
		}
		
		/** Интерфейс */
		
		public function setCommand(c:ICommand):void {
			_currentCommand = c;
			executeCommand();
		}
		
		public function executeCommand():void {
			_currentCommand.execute();
		}
		
		public function dispose():void {
			
		}
	}
}