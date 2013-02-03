package tree.command {
import tree.signal.RequestSignal;
import tree.signal.ResponseSignal;

/**
 * Сохранить координаты ручной расстановки
 */
public class SaveTree extends Command{

	public var request:RequestSignal;
	public var silent:Boolean;

	public function SaveTree(silent:Boolean = false) {
		request = new RequestSignal(RequestSignal.SAVE_TREE);
		this.silent = silent;
	}

	override public function execute():void {
		request.onSucces.add(onTreeSaved);
		request.silent = silent;
		call(request);
		detain();
	}

	private function onTreeSaved(response:ResponseSignal):void {
		release();
		model.handLog.clear();
	}
}
}
