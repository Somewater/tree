package tree.manager {
import com.somewater.storage.I18n;

import tree.common.Bus;
	import tree.common.Config;
	import tree.model.Join;
import tree.model.Model;
import tree.signal.RequestSignal;
	import tree.loader.IServerHandler;
import tree.signal.ResponseSignal;
import tree.signal.ResponseSignal;
import tree.view.window.MessageWindow;
import tree.view.window.TitleTextWindow;

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
					request.onSucces.add(processTree)
//					if(CONFIG::debug){
//						data = '<?xml version="1.0" encoding="utf-8"?><familytree><setup><option name="readonly">1</option><option name="auth_user_id">0</option><option name="tree_user_id">18985299</option><option name="mode">asc</option><option name="animation">1</option><option name="filter">0</option><option name="current_year">2012</option><option name="zoom">100</option></setup><trees><tree uid="18985299" name="Дерево пользователя 18985299"><node uid="83201051" name="" open="0" edit_access="0" domain=""><fields></fields><relatives><group type="7"><node uid="18985299" status="1" /></group><group type="5"><node uid="27090998" status="1" /><node uid="28829363" status="1" /><node uid="99381957" status="1" /></group><group type="3"><node uid="34274364" status="1" /></group></relatives></node><node uid="62659942" name="" open="0" edit_access="0" domain=""><fields></fields><relatives><group type="5"><node uid="18985299" status="1" /><node uid="45538540" status="1" /></group><group type="8"><node uid="55690559" status="1" /></group></relatives></node><node uid="55690559" name="" open="0" edit_access="0" domain=""><fields></fields><relatives><group type="5"><node uid="18985299" status="1" /><node uid="45538540" status="1" /></group><group type="7"><node uid="62659942" status="1" /></group></relatives></node><node uid="45538540" name="" open="0" edit_access="0" domain=""><fields></fields><relatives><group type="3"><node uid="18985299" status="1" /></group><group type="6"><node uid="27604899" status="1" /><node uid="87936089" status="1" /></group><group type="8"><node uid="46325019" status="1" /></group><group type="2"><node uid="55690559" status="1" /></group><group type="1"><node uid="62659942" status="1" /></group></relatives></node><node uid="27090998" name="" open="0" edit_access="0" domain=""><fields></fields><relatives><group type="1"><node uid="18985299" status="1" /></group><group type="3"><node uid="28829363" status="1" /><node uid="99381957" status="1" /></group><group type="2"><node uid="83201051" status="1" /></group></relatives></node><node uid="99381957" name="" open="0" edit_access="0" domain=""><fields></fields><relatives><group type="1"><node uid="18985299" status="1" /></group><group type="3"><node uid="27090998" status="1" /><node uid="28829363" status="1" /></group><group type="2"><node uid="83201051" status="1" /></group></relatives></node><node uid="28829363" name="" open="0" edit_access="0" domain=""><fields></fields><relatives><group type="1"><node uid="18985299" status="1" /></group><group type="3"><node uid="27090998" status="1" /><node uid="99381957" status="1" /></group><group type="2"><node uid="83201051" status="1" /></group></relatives></node><node uid="46325019" name="" open="0" edit_access="0" domain=""><fields></fields><relatives><group type="6"><node uid="27604899" status="1" /><node uid="87936089" status="1" /></group><group type="7"><node uid="45538540" status="1" /></group></relatives></node><node uid="27604899" name="" open="0" edit_access="0" domain=""><fields></fields><relatives><group type="1"><node uid="45538540" status="1" /></group><group type="2"><node uid="46325019" status="1" /></group><group type="4"><node uid="87936089" status="1" /></group></relatives></node><node uid="87936089" name="" open="0" edit_access="0" domain=""><fields></fields><relatives><group type="4"><node uid="27604899" status="1" /></group><group type="1"><node uid="45538540" status="1" /></group><group type="2"><node uid="46325019" status="1" /></group></relatives></node><node uid="67829833" name="" open="0" edit_access="0" domain=""><fields></fields></node><node uid="34274364" name="" open="0" edit_access="0" domain=""><fields></fields><relatives><group type="2"><node uid="37268947" status="1" /></group><group type="3"><node uid="67157607" status="1" /></group><group type="4"><node uid="83201051" status="1" /></group></relatives></node><node uid="37268947" name="" open="0" edit_access="0" domain=""><fields></fields><relatives><group type="5"><node uid="34274364" status="1" /><node uid="67157607" status="1" /></group><group type="9"><node uid="67829833" status="1" /></group></relatives></node><node uid="67157607" name="" open="0" edit_access="0" domain=""><fields></fields><relatives><group type="3"><node uid="34274364" status="1" /></group></relatives></node><node uid="18985299" name="Я Я" open="1" edit_access="0" domain="http://fs19.familyspace.ru/"><fields><field name="last_name">Я</field><field name="first_name">Я</field><field name="middle_name"></field><field name="maiden_name"></field><field name="birthday">0000-00-00</field><field name="died">0</field><field name="deathday">0000-00-00</field><field name="sex">1</field><field name="active">1</field><field name="url">http://www.familyspace.ru/user18985299</field><field name="photo_small">http://static.familyspace.ru/i/system/users/u2_nophoto1.png</field></fields><relatives><group type="5"><node uid="27090998" status="1" /><node uid="28829363" status="1" /><node uid="99381957" status="1" /></group><group type="3"><node uid="45538540" status="1" /></group><group type="2"><node uid="55690559" status="1" /></group><group type="1"><node uid="62659942" status="1" /></group><group type="8"><node uid="83201051" status="1" /></group></relatives></node></tree></trees></familytree>';
//						processTree(data as String)
//					}
//					else
					handler.call({"action":"q_tree", "taction":"userlist", "uid":request.uid}, onSuccess(request),
							onError(request), onInitLoadingProgress);
				break;

				case RequestSignal.DELETE_USER:
					bus.loaderProgress.dispatch(0);
					request.onComplete.add(hideLoader);
					handler.call({
						'action': 'q_tree',
						'taction':'delete_user',
						'uid': model.trees.first.owner.uid,
						'user_id': request.person.uid
					}, onSuccess(request), onError(request), onProgress);
				break;

				case RequestSignal.ADD_USER:
					bus.loaderProgress.dispatch(0);
					request.onComplete.add(hideLoader);
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
					handler.call(deleteNullFields(data), onSuccess(request), onError(request), onProgress);
				break;

				case RequestSignal.EDIT_USER:
					bus.loaderProgress.dispatch(0);
					request.onComplete.add(hideLoader);
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
					if(request.joinFrom) data['for'] = request.joinFrom.uid;
					if(request.joinType) data['rel'] = Join.typeToServer(request.joinType);
					handler.call(deleteNullFields(data), onSuccess(request), onError(request), onProgress);
				break;

				case RequestSignal.ADD_RELATION:
					bus.loaderProgress.dispatch(0);
					request.onComplete.add(hideLoader);
					data = {
						'action': 'q_tree',
						'uid': model.trees.first.owner.uid,
						'taction': 'add_relative',
						'from_id':request.joinFrom.uid,
						'to_id':request.person.uid,
						'rel_type':Join.typeToServer(request.joinType)
					}
					handler.call(deleteNullFields(data), onSuccess(request), onError(request), onProgress);
					break;

				case RequestSignal.SAVE_TREE:
					bus.loaderProgress.dispatch(0);
					request.onComplete.add(hideLoader);
					data = {
						'action': 'q_tree',
						'uid': model.trees.first.owner.uid,
						'taction': 'save',
						'data': model.handLog.formatPrint()
					};
					handler.call(deleteNullFields(data), onSuccess(request), onError(request), onProgress);
					break;

				default:
					throw new Error('Undefined request type \'' + request.type+ '\'');
				break;
			}
		}

		private function onSuccess(request:RequestSignal):Function{
			return function(data:Object):void{
				var response:ResponseSignal = new ResponseSignal(ResponseSignal.SUCCESS, data, request)
				// проверить application error
				var applicationError:Boolean = false;
				try{
					if(response.getErrorMessage()){
						response.type = ResponseSignal.ERROR;
						applicationError = true;
					}
				}catch(err:Error){
				}

				if(applicationError){
					onError(response.request)(response.data);
				}else{
					request.onSucces.dispatch(response);
					bus.dispatch(ResponseSignal.SIGNAL, response);
					request.onComplete.dispatch(response);
					request.clear();

					if(response.getMessage() && !response.silent())
						new TitleTextWindow(I18n.t('SERVER_RESPONSE'), response.getMessage());
				}
			}
		}

		private function onError(request:RequestSignal):Function {
			return function(data:Object = null):void{
				var response:ResponseSignal = new ResponseSignal(ResponseSignal.ERROR, data, request)
				request.onError.dispatch(response);
				bus.dispatch(ResponseSignal.SIGNAL, response);
				request.onComplete.dispatch(response);
				if(!response.errorHandler && response.getMessage())
					new TitleTextWindow(I18n.t('SERVER_ERROR'), response.getMessage());
				request.clear();
			}
		}

		private function onInitLoadingProgress(progress:Number):void{
			bus.initialLoadingProgress.dispatch(0, progress);
		}

		private function onProgress(progress:Number):void{
			bus.loaderProgress.dispatch(progress);
		}

		private function processTree(response:ResponseSignal):void {
			bus.initialLoadingProgress.dispatch(1, 0);
			Config.ticker.callLater(processTree_createXML, 1, [response.toString()])
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
				bus.loaderProgress.dispatch();
				return;
			}
		}

		private function processTree_dispatchComplete(xml:XML):void{
			bus.dispatch(ResponseSignal.SIGNAL, new ResponseSignal(RequestSignal.USER_TREE, xml, null));
		}

		private  function hideLoader(response:ResponseSignal):void{
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
				if(!(data[key] === null))
					newData[key] = data[key];
			return newData;
		}
	}
}
