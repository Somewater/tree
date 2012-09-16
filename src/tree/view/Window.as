package tree.view {
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;

	import tree.common.IClear;

	public class Window extends Sprite implements IWindow, IClear{

		protected var _width:int = 400;
		protected var _height:int = 200;

		public function Window() {
			resize();
		}

		public function open():void {
			WindowsManager.instance.add(this);
			WindowsManager.instance.centre(this);
		}

		public function close():void {
			WindowsManager.instance.remove(this);
		}

		public function get modal():Boolean {
			return false;
		}

		public function get individual():Boolean {
			return false;
		}

		public function get priority():int {
			return 0;
		}


		override public function get width():Number {
			return _width;
		}

		override public function get height():Number {
			return _height;
		}


		override public function set width(value:Number):void {
			_width = value;
			resize();
		}


		override public function set height(value:Number):void {
			_height = value;
			resize();
		}

		public function setSize(width:int, height:int):void {
			_width = width;
			_height = height;
			resize();
		}

		protected function resize():void {
			graphics.clear();

			graphics.beginFill(0xCCCCCC);
			graphics.drawRect(0, 0, _width, _height);

			graphics.beginFill(0xFFFF88);
			graphics.drawRect(0, 0, _width, 20);
		}

		public function clear():void{

		}
	}
}
