package tree.view.window {
import com.somewater.storage.I18n;

import tree.command.SaveTree;

import tree.command.SaveTree;

import tree.model.Model;
import tree.signal.ResponseSignal;

import tree.view.Window;
import tree.view.WindowsManager;

public class SaveTreeAcceptWindow extends AcceptWindow{
	public function SaveTreeAcceptWindow(lock:Lock, yes:Function, no:Function) {
		super(I18n.t('ATTENTION'), I18n.t('HAND_DATA_SAVE_WND'), yes, no);
	}

	/**
	 * cb()
	 */
	public static function check(cb:Function):void{
		if(Model.instance.handLog.empty())
			cb();
		else{
			var w:SaveTreeAcceptWindow = new SaveTreeAcceptWindow(new Lock(), function():void{
				onWindowClosed(true, cb);
			}, function():void{
				onWindowClosed(false, cb);
			});
			WindowsManager.instance.add(w);
		}
	}

	private static function onWindowClosed(yes:Boolean, cb:Function):void{
		if(yes){
			var c:SaveTree = new SaveTree();
			c.request.onComplete.add(function(response:ResponseSignal):void{
				cb();
			});
			c.execute();
		}else{
			cb();
		}
	}
}
}
class Lock{

}
