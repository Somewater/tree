package tree.command {
	import flash.net.URLVariables;

	import tree.common.Config;
	import tree.signal.RequestSignal;

	public class StartupCommand extends Command{

		private var requiredId:int;

		public function StartupCommand(requiredId:int = 0) {
			this.requiredId = requiredId;
		}

		override public function execute():void {


			// начать загрузку дерева, в соответствии с flashVars
			var request:RequestSignal = new RequestSignal(RequestSignal.USER_TREE);

			var get:String = Config.loader.flashVars['get']
			var uid:int = 0;
			if(get && get.length)
			{
				var v:URLVariables = new URLVariables(get);
				uid = v.uid;
			}
			request.uid = requiredId || uid || 3;// 18985299 (my), 36007,  84001 (4.5k)
			call(request);
		}
	}
}
