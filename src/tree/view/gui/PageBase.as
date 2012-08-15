package tree.view.gui {
	import flash.display.Sprite;

	import tree.common.IClear;

	public class PageBase extends UIComponent implements IClear{

		protected var _width:int;
		protected var _height:int;

		public function PageBase() {
		}

		public function get pageName():String{
			throw new Error('Implement me');
		}

		public function setSize(w:int, h:int):void{
			_width = w;
			_height = h;
			resize();
		}

		public function resize():void{
			fireResize();
		}
	}
}
