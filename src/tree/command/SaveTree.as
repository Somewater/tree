package tree.command {
import tree.signal.RequestSignal;
import tree.signal.ResponseSignal;

public class SaveTree extends Command{

	public var request:RequestSignal;

	public function SaveTree() {
		request = new RequestSignal(RequestSignal.SAVE_TREE);
	}

	override public function execute():void {
		request.onSucces.add(onTreeSaved);
		call(request);
		detain();
	}

	private function onTreeSaved(response:ResponseSignal):void {
		release();
		model.handLog.clear();
	}
}
}
