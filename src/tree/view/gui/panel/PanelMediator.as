package tree.view.gui.panel {
	import tree.common.Config;
	import tree.view.Mediator;

	public class PanelMediator extends Mediator{

		private var panel:Panel;
		private var controller:PanelController;

		public function PanelMediator(panel:Panel) {
			this.panel = panel;
			this.controller = new PanelController(panel);
			super(panel);
		}

		override protected function refresh():void {
			panel.setSize(Config.WIDTH - Config.GUI_WIDTH, Config.PANEL_HEIGHT);
		}
	}
}
