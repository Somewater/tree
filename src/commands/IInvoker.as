package commands {
	
	public interface IInvoker {
			
		function setCommand(c:ICommand):void;
		function executeCommand():void;
	}
}