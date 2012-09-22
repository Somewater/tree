package tree.view.gui {
	import flash.display.DisplayObject;

	import tree.command.Actor;
	import tree.common.IClear;

	public class GuiControllerBase extends Actor implements IClear{

		private var view:PageBase
		public var gui:Gui;

		public function GuiControllerBase(view:PageBase) {
			this.view = view;
		}

		public function start():void{

		}

		public function stop():void{
			clear();
		}

		public function clear():void {
			gui = null;
		}
	}
}
