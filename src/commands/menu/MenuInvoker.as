package commands.menu {
	
	import commands.ICommand;
	import commands.IInvoker;
	
	public class MenuInvoker implements IInvoker,IDisposable {
		
		private var _currentCommand:ICommand;
		
		public function MenuInvoker() {
			
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