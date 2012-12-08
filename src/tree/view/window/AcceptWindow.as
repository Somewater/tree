package tree.view.window {
import com.somewater.storage.I18n;

import org.osflash.signals.ISignal;
import org.osflash.signals.Signal;

import tree.view.gui.Button;
import tree.view.gui.StandartButton;

public class AcceptWindow extends TitleTextWindow{

	protected var cancelButton:Button;

	public var onYes:ISignal;// callback()
	public var onNo:ISignal;// callback()
	public var onComplete:ISignal;// callback()

	/**
	 *
	 * @param title
	 * @param text
	 * @param onYes callback()
	 * @param onNo callback()
	 */
	public function AcceptWindow(title:String, text:String, onYes:Function = null, onNo:Function = null) {
		super(title, text);

		okButton.label = I18n.t('YES')
		cancelButton = new StandartButton();
		cancelButton.height = okButton.height;
		cancelButton.label = I18n.t('CANCEL');
		addChild(cancelButton);
		cancelButton.click.add(onCancelClicked);
		resize();

		this.onYes = new Signal();
		this.onNo = new Signal();
		this.onComplete = new Signal();

		if(onYes != null) this.onYes.add(onYes);
		if(onNo != null) this.onNo.add(onNo);
	}

	override public function clear():void {
		super.clear();
		onYes.removeAll();
		onNo.removeAll();
		cancelButton.clear();
		onComplete.removeAll();
	}

	override protected function onOkClicked(b:Button):void {
		onComplete.dispatch();
		onYes.dispatch();
		close();
	}

	private function onCancelClicked(b:Button):void {
		onComplete.dispatch();
		onNo.dispatch();
		close();
	}

	override protected function resize():void {
		super.resize();

		if(!cancelButton) return;
		cancelButton.x = okButton.x + okButton.width + 15;
		cancelButton.y = okButton.y;
	}

	public function get yesButton():Button{
		return okButton;
	}

	public function get noButton():Button{
		return cancelButton;
	}
}
}
