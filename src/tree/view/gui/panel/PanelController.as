package tree.view.gui.panel {
	import tree.command.Actor;

	public class PanelController extends Actor{

		private var panel:Panel;

		public function PanelController(panel:Panel) {
			this.panel = panel;
		}
	}
}
