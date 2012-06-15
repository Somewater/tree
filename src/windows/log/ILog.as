package windows.log {
	
	public interface ILog {
		
		function append(string:String):void;
		function clearText():void;
		function kill():void;
	}
}