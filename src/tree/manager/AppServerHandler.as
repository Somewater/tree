package tree.manager {
	import tree.common.Bus;
	import tree.signal.RequestSignal;
	import tree.loader.IServerHandler;
	import tree.signal.ResponseSignal;

	public class AppServerHandler {

		public static var instance:AppServerHandler;

		private var handler:IServerHandler;
		private var bus:Bus;

		public function AppServerHandler(handler:IServerHandler, bus:Bus) {
			this.handler = handler;
			this.bus = bus;
		}

		public function call(request:RequestSignal):void
		{
			switch(request.type)
			{
				case RequestSignal.USER_TREE:
					handler.call({"action":"userlist", "uid":request.uid}, processTree, onError);
				break;

				default:
					throw new Error('Undefined request type \'' + request.type+ '\'');
				break;
			}
		}

		private function onError(...args):void {
			bus.dispatch(ResponseSignal.SIGNAL, new ResponseSignal(ResponseSignal.ERROR, null))
		}

		private function processTree(data:String):void {
			var xml:XML
			try{
				xml = new XML(data);
			}catch(err:Error){
				onError(err);
				return;
			}

			bus.dispatch(ResponseSignal.SIGNAL, new ResponseSignal(RequestSignal.USER_TREE, xml));
		}
	}
}
