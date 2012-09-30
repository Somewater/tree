package tree.manager {
	public interface ITicker {
		function callLater(callback:Function, frames:int = 1, args:Array = null):void;
		function removeByCallback(callback:Function):void;
		function defer(callback:Function, ms:int, args:Array = null):void

		function add(tick:ITick):void;
		function remove(tick:ITick):void;

		function get getTimer():uint;
	}
}
