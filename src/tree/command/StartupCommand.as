package tree.command {
	import flash.net.URLVariables;

	import tree.common.Config;
import tree.model.Model;
import tree.signal.RequestSignal;

	public class StartupCommand extends Command{

		private var requiredId:int;

		public function StartupCommand(requiredId:int = 0) {
			this.requiredId = requiredId;
		}

		override public function execute():void {
			// начать загрузку дерева, в соответствии с flashVars
			var request:RequestSignal = new RequestSignal(RequestSignal.USER_TREE);
			request.uid = requiredId || model.user.uid;
			CONFIG::debug{
				request.uid ||= Model.DEFAULT_UID ;// 18985299 (my), 36007,  84001 (4.5k)
			}
			call(request);
		}
	}
}
