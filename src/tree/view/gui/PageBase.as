package tree.view.gui {
	import flash.display.Sprite;

	import tree.common.Bus;
	import tree.common.Config;

	import tree.common.IClear;
	import tree.model.Model;

	public class PageBase extends UIComponent implements IClear{

		protected var bus:Bus;
		protected var model:Model;

		public function PageBase() {
			this.bus = Config.inject(Bus);
			this.model = Config.inject(Model);
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
