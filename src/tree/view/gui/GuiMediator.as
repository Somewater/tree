package tree.view.gui {
	import tree.common.Config;
	import tree.view.Mediator;

	public class GuiMediator extends Mediator{

		private var gui:Gui;

		public function GuiMediator(gui:Gui) {
			this.gui = gui;
			super(gui);
		}

		override public function clear():void {
			super.clear();
			gui = null;
		}

		override protected function refresh():void {
			if(Config.WIDTH > Config.GUI_WIDTH)
			{
				gui.setSize(Config.GUI_WIDTH, Config.HEIGHT);
				gui.x = Config.WIDTH - Config.GUI_WIDTH;
				gui.visible = true;
			}
			else
				gui.visible = false;

			// todo: перевести интерфейс в необходимое состояние
		}
	}
}
