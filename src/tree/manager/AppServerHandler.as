package tree.manager {
	import tree.common.Bus;
	import tree.common.Config;
	import tree.model.Join;
import tree.model.Model;
import tree.signal.RequestSignal;
	import tree.loader.IServerHandler;
	import tree.signal.ResponseSignal;
import tree.view.window.MessageWindow;

public class AppServerHandler {

		public static var instance:AppServerHandler;

		private var handler:IServerHandler;
		private var bus:Bus;
		private var model:Model;

		public function AppServerHandler(handler:IServerHandler, bus:Bus, model:Model) {
			this.handler = handler;
			this.bus = bus;
			this.model = model;
		}

		public function call(request:RequestSignal):void
		{
			var data:Object;
			switch(request.type)
			{
				case RequestSignal.USER_TREE:
					bus.initialLoadingProgress.dispatch(0, 0);
					handler.call({"action":"q_tree", "taction":"userlist", "uid":request.uid}, processTree, onError(request), xmlDataLoadingProgress);
				break;

				case RequestSignal.DELETE_USER:
					bus.loaderProgress.dispatch(0);
					handler.call({
						'action': 'q_tree',
						'taction':'delete_user',
						'uid': model.trees.first.owner.uid,
						'user_id': request.person.uid
					}, delegate(request, processDelete), onError(request), onProgress);
				break;

				case RequestSignal.ADD_USER:
					bus.loaderProgress.dispatch(0);
					data = {
						'action': 'q_tree',
						'uid': model.trees.first.owner.uid,
						'taction': 'add_user',
						'last_name': request.person.lastName,
						'first_name': request.person.firstName,
						'middle_name': request.person.middleName,
						'maiden_name': request.person.maidenName,
						'sex': (request.person.male ? 1 : 0),
						'birthday': dateToDatabaseFormat(request.person.birthday),
						'deathday': dateToDatabaseFormat(request.person.deathday),
						'died': request.person.died ? 1 : 0,
						'email': request.person.email
					};
					if(request.joinFrom) data['for'] = request.joinFrom.uid;
					if(request.joinType) data['rel'] = Join.typeToServer(request.joinType);
					handler.call(deleteNullFields(data), delegate(request, processAddPerson), onError(request), onProgress);
				break;

				case RequestSignal.EDIT_USER:
					bus.loaderProgress.dispatch(0);
					data = {
						'action': 'q_tree',
						'uid': model.trees.first.owner.uid,
						'user_id': request.person.uid,
						'taction': 'edit_user',
						'last_name': request.person.lastName,
						'first_name': request.person.firstName,
						'middle_name': request.person.middleName,
						'maiden_name': request.person.maidenName,
						'sex': (request.person.male ? 1 : 0),
						'birthday': dateToDatabaseFormat(request.person.birthday),
						'deathday': dateToDatabaseFormat(request.person.deathday),
						'died': request.person.died ? 1 : 0,
						'email': request.person.email
					}
					handler.call(deleteNullFields(data), delegate(request, processEdit), onError(request), onProgress);
				break;

				default:
					throw new Error('Undefined request type \'' + request.type+ '\'');
				break;
			}
		}

		private function delegate(request:RequestSignal, cb:Function):Function{
			return function(response:Object):void{
				cb(request, new ResponseSignal(ResponseSignal.SUCCESS, response, request))
			}
		}

		private function onError(request:RequestSignal):Function {
			return function(response:Object = null):void{
				bus.loaderProgress.dispatch();
				bus.dispatch(ResponseSignal.SIGNAL, new ResponseSignal(ResponseSignal.ERROR, response, request));
				if(response)
					new MessageWindow(response.toString()).open();
			}
		}

		private function xmlDataLoadingProgress(progress:Number):void{
			bus.initialLoadingProgress.dispatch(0, progress);
		}

		private function onProgress(progress:Number):void{
			bus.loaderProgress.dispatch(progress);
		}

		private function processTree(data:String):void {
			bus.initialLoadingProgress.dispatch(1, 0);
			Config.ticker.callLater(processTree_createXML, 1, [data])
		}

		private function processTree_createXML(data:String):void{
			var xml:XML
			try{
				xml = new XML(data);
				bus.initialLoadingProgress.dispatch(1, 1);
				Config.ticker.callLater(processTree_dispatchComplete, 1, [xml])
			}catch(err:Error){
				error(err);
				bus.dispatch(ResponseSignal.SIGNAL, new ResponseSignal(ResponseSignal.ERROR, data, null));
				return;
			}
		}

		private function processTree_dispatchComplete(xml:XML):void{
			bus.dispatch(ResponseSignal.SIGNAL, new ResponseSignal(RequestSignal.USER_TREE, xml, null));
		}

		private  function processEdit(request:RequestSignal, response:ResponseSignal):void{
			bus.loaderProgress.dispatch();
		}

		private  function processAddPerson(request:RequestSignal, response:ResponseSignal):void{
			bus.loaderProgress.dispatch();
		}

		private  function processDelete(request:RequestSignal, response:ResponseSignal):void{
			bus.loaderProgress.dispatch();
		}

		/////////////////////////////////
		//                             //
		//   U T I L S  M E T H O D S  //
		//                             //
		/////////////////////////////////

		private function dateToDatabaseFormat(date:Date):String {
			if(date)
				return date.getFullYear() + '-' + toDouble(date.getMonth() + 1) + '-' + toDouble(date.getDate());
			else
				return '';
		}

		private function toDouble(data:int):String{
			return (data < 10 ? '0' + data : data + '');
		}

		private function deleteNullFields(data:Object):Object{
			var newData:Object = {};
			for(var key:String in data)
				if(data[key] !== null)
					newData[key] = data[key];
			return newData;
		}
	}
}
