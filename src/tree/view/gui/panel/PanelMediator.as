package tree.view.gui.panel {
	import com.junkbyte.console.Cc;

	import tree.command.ToggleFullScreen;
	import tree.common.Config;
	import tree.view.Mediator;
	import tree.view.gui.Button;

	public class PanelMediator extends Mediator{

		private var panel:Panel;
		private var controller:PanelController;

		public function PanelMediator(panel:Panel) {
			this.panel = panel;
			this.controller = new PanelController(panel);
			super(panel);

			panel.fullscreenButton.click.add(onFullscreenClicked);
		}

		override protected function refresh():void {
			panel.setSize(Config.WIDTH - Config.GUI_WIDTH, Config.PANEL_HEIGHT);
		}

		private function onFullscreenClicked(b:Button):void {
			new ToggleFullScreen().execute();
		}
	}
}
