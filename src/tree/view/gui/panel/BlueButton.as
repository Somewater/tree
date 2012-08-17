package tree.view.gui.panel {
	import tree.view.gui.Button;
	import com.somewater.storage.I18n;
	import com.somewater.text.EmbededTextField;

	import tree.common.Config;

	public class BlueButton extends Button{
		public function BlueButton() {
			super(Config.loader.createMc('assets.SaveButtonBackground'));
			textField = new EmbededTextField(null, 0xFFFFFF, 13, true);
		}
	}
}
