package tree.view {
	public interface IWindow {
		function get width():Number;
		function get height():Number;
		function get x():Number;
		function get y():Number;
		function set x(v:Number):void;
		function set y(v:Number):void;

		function setSize(width:int, height:int):void;

		function open():void
		function close():void

		function get modal():Boolean;
		function get individual():Boolean;
		function get priority():int;
	}
}
