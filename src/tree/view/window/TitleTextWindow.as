package tree.view.window {
import com.somewater.storage.I18n;
import com.somewater.text.EmbededTextField;

import tree.common.Config;

import tree.view.Window;
import tree.view.WindowsManager;
import tree.view.gui.Button;
import tree.view.gui.StandartButton;

public class TitleTextWindow extends Window{

	private var titleTF:EmbededTextField;
	private var textTF:EmbededTextField;
	protected var okButton:Button;

	public function TitleTextWindow(title:String, text:String) {
		super();

		titleTF = new EmbededTextField(null, 0, 15, true);
		addChild(titleTF);

		textTF = new EmbededTextField(null, 0, 13, false, true);
		addChild(textTF);

		okButton = new StandartButton();
		okButton.label = I18n.t('OK');
		okButton.height = 32;
		okButton.click.add(onOkClicked);
		addChild(okButton);

		this.title = title;
		this.text = text;
		open();
	}

	override public function clear():void {
		okButton.clear();
		super.clear();
	}

	public function set title(value:String):void{
		titleTF.text = value;
		resize();
		WindowsManager.instance.centre(this);
	}

	public function set text(value:String):void{
		textTF.text = value;
		resize();
		WindowsManager.instance.centre(this);
	}

	override protected function resize():void {
		if(!textTF) return;

		// при необходимости, изменить размер

		var minDefaultWidth:int = Math.max(titleTF.length, textTF.length)* 0.75 + 225;
		var newWidth:int = Math.min(Config.WIDTH * 0.9, Math.max(textTF.textWidth + 20, titleTF.textWidth + 20, minDefaultWidth, 300));
		titleTF.width = textTF.width = newWidth;
		titleTF.x = 15;
		titleTF.y = 10;
		textTF.x = titleTF.x;
		textTF.y = titleTF.y + titleTF.textHeight + 20;
		okButton.x = textTF.x;
		okButton.y = textTF.y + textTF.textHeight + 15;
		var newHeight:int = okButton.y + okButton.height + 15;

		_width = newWidth + 30;
		_height = newHeight;

		super.resize();
	}

	protected function onOkClicked(b:Button):void{
		close();
	}
}
}
