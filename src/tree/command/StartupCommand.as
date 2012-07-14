package tree.command {
	import flash.net.URLVariables;

	import tree.common.Config;
	import tree.signal.RequestSignal;

	public class StartupCommand extends Command{
		public function StartupCommand() {
		}

		override public function execute():void {

			bus.loaderProgress.dispatch(0);

			// начать загрузку дерева, в соответствии с flashVars
			var request:RequestSignal = new RequestSignal(RequestSignal.USER_TREE);

			var get:String = Config.loader.flashVars['get']
			var uid:int = 0;
			if(get && get.length)
			{
				var v:URLVariables = new URLVariables(get);
				uid = v.uid;
			}
			request.uid = uid || 0;// 18985299 36007
			call(request);
		}
	}
}
