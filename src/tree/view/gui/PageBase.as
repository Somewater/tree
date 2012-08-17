package tree.view.gui {
	import flash.display.Sprite;

	import tree.common.IClear;

	public class PageBase extends UIComponent implements IClear{

		public function PageBase() {
		}

		public function get pageName():String{
			throw new Error('Implement me');
		}

		override protected function refresh():void{
			super.refresh();
			fireResize();
		}
	}
}
