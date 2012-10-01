package tree.manager {
	import tree.common.Bus;
	import tree.common.Config;
	import tree.model.Join;
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
					handler.call({"action":"q_tree", "taction":"userlist", "uid":request.uid}, processTree, onError, onProgress);
				break;

				case RequestSignal.DELETE_USER:
					handler.call({'action': 'q_tree', 'taction':'<undefined>', 'uid': request.uid}, checkResponse, onError, onProgress);
				break;

				case RequestSignal.ADD_USER:
					handler.call({
									'action': 'q_tree',
									'uid': request.addedJoin.associate.tree.uid,
									'for': request.addedJoin.from.uid,
									'rel': Join.typeToServer(request.addedJoin.type),
									'taction': 'add_user',
									'last_name': request.addedJoin.associate.lastName,
									'first_name': request.addedJoin.associate.firstName,
									'middle_name': request.addedJoin.associate.middleName,
									'maiden_name': request.addedJoin.associate.maidenName,
									'sex': (request.addedJoin.associate.male ? 1 : 0),
									'birthday': dateToDatabaseFormat(request.addedJoin.associate.birthday),
									'deathday': dateToDatabaseFormat(request.addedJoin.associate.deathday),
									'died': request.addedJoin.associate.died,
									'email': request.addedJoin.associate.email
								}, checkResponse, onError, onProgress);
				break;

				default:
					throw new Error('Undefined request type \'' + request.type+ '\'');
				break;
			}
		}

		private function checkResponse(...args):void{
			// todo
		}

		private function onError(...args):void {
			bus.dispatch(ResponseSignal.SIGNAL, new ResponseSignal(ResponseSignal.ERROR, null));
		}

		private function onProgress(progress:Number):void{
			bus.loaderProgress.dispatch(progress);
		}

		private function processTree(data:String):void {
			Config.ticker.callLater(processTree_createXML, 1, [data])
		}

		private function processTree_createXML(data:String):void{
			var xml:XML
			try{
				xml = new XML(data);
				Config.ticker.callLater(processTree_dispatchComplete, 1, [xml])
			}catch(err:Error){
				error(err);
				onError(err);
				return;
			}
		}

		private function processTree_dispatchComplete(xml:XML):void{
			bus.dispatch(ResponseSignal.SIGNAL, new ResponseSignal(RequestSignal.USER_TREE, xml));
		}

		private function dateToDatabaseFormat(date:Date):String {
			if(date)
				return date.getFullYear() + '-' + toDouble(date.getMonth() + 1) + '-' + toDouble(date.getDate());
			else
				return '0000-00-00';
		}

		private function toDouble(data:int):String{
			return (data < 10 ? '0' + data : data + '');
		}
	}
}
