package tree.view.canvas {
import com.somewater.storage.I18n;
import com.somewater.text.EmbededTextField;

import tree.common.Config;
import tree.view.gui.Button;

public class ContextMenuBtn extends Button{

	public function ContextMenuBtn() {
		super(Config.loader.createMc('assets.ContextMenuBtn'))
		textField = new EmbededTextField(null, 0x333333, 10, true);

		label = I18n.t('ADD');
	}
}
}
