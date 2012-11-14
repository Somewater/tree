package tree.view.gui {
import fl.controls.TextInput;

import flash.text.TextFormat;

public class TreeTextInput extends TextInput{
	public function TreeTextInput() {
		super();

		var format:TextFormat = new TextFormat();
		format.size = 13;
		textField.setTextFormat(format);
		textField.defaultTextFormat = format;

		setStyle('textPadding', 4);
		height = 28;
	}
}
}
