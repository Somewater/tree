package tree.view.gui {
	import flash.display.Sprite;

	import tree.common.Bus;
	import tree.common.Config;

	import tree.common.IClear;

	public class PageBase extends UIComponent implements IClear{

		protected var bus:Bus;

		public function PageBase() {
			this.bus = Config.inject(Bus);
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
