package tree.view.gui {
	import flash.events.MouseEvent;

	import tree.common.Config;
	import tree.view.Mediator;

	public class GuiMediator extends Mediator{

		private var gui:Gui;
		private var controller:GuiController;

		public function GuiMediator(gui:Gui) {
			this.gui = gui;
			this.controller = new GuiController(gui);
			super(gui);

			//gui.addEventListener(MouseEvent.CLICK, onPanelClicked);
		}

		override public function clear():void {
			super.clear();
			gui = null;
		}

		override protected function refresh():void {
			if(Config.WIDTH > Config.GUI_WIDTH)
			{
				gui.setSize(Config.GUI_WIDTH, Config.HEIGHT);
				if(model.guiOpen)
					gui.x = Config.WIDTH - Config.GUI_WIDTH;
				else
					gui.x = Config.WIDTH;
				gui.visible = true;
				gui.contentVisibility = model.guiOpen;
			}
			else
				gui.visible = false;

			// todo: перевести интерфейс в необходимое состояние
		}

		private function onPanelClicked(event:MouseEvent):void {
			controller.addPerson();
		}
	}
}
