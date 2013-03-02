package tree.model {
	import org.osflash.signals.ISignal;

	import tree.Tree;
import tree.common.Config;

import tree.model.base.ICollection;
	import tree.model.base.IModel;
	import tree.model.base.ModelCollection;

	/**
	 * Модель человека. Одновременно, является коллекцией join
	 */
	public class Person extends JoinCollectionBase implements IModel, ICollection{

		public static const PHOTO_SMALL:int = 0;
		public static const PHOTO_BIG:int = 1;

		public var male:Boolean;

		public var photoSmall:String;
		public var photoBig:String;
		public var isNew:Boolean = false;

		private var _editable:Boolean = false;// флаг, который игнорируется, если false и форсированно используется, если true

		public function photo(size:int = 0):String{
			var value:String;
			if(size == 0){
				value = photoSmall ? photoSmall : photoBig;
			}else if(size == 1){
				value = photoBig ? photoBig : photoSmall;
			}
			if(value && value.length > 0)
				return value;
			else
				return male ? Model.instance.options.defaultMalePhoto : Model.instance.options.defaultFemalePhoto;
		}

		public var tree:TreeModel;

		public var firstName:String = '';
		public var lastName:String = '';
		public var middleName:String = '';
		public var maidenName:String;
		public var birthday:Date;
		public var deathday:Date;
		private var _died:Boolean = false;
		public var email:String;
		public var post:String;
		public var profileUrl:String;

		private var _name:String = 'Undefined';// название ноды, если у него нет ФИО

		public var homePlace:String;
		public var birthPlace:String;

		public var urls:Urls = new Urls();

		public  var open:Boolean = true;

		public var fields:PersonFields = new PersonFields();

		public function Person(tree:TreeModel) {
			this.tree = tree;
		}

		override public function get id():String {
			return uid + '';
		}

		public function get female():Boolean{return !male;}

		public function toString():String {
			return '[' + this.name + ' ' + uid + ' (' + (this.male ? 'male' : 'female') + ')]';
		}

		public function get node():Node {
			var t:TreeModel = this.tree
			return t ? t.nodes.get(this.uid + '') : null;
		}

		public function dirtyMattyCache():void {
			_marryCalculated = false;
		}

		public function get name():String {
			return open ? lastName || firstName ? lastName + ' ' + firstName : uid.toString() : _name;
		}

		public function set name(value:String):void{
			if(!open)
				_name = value;
			else
				throw new Error("Cant't assign name for open node");
		}

		public function get fullname():String {
			return (lastName || firstName || middleName) ? lastName + ' ' + firstName + ' ' + middleName : uid.toString();
		}

		public function get died():Boolean{
			return open && (hasDeathdayDate || _died);
		}

		public function set died(value:Boolean):void{
			if(value){
				_died = true;
			}else{
				_died = false;
				deathday = null;
			}
		}

		public function get readonly():Boolean{
			return false;
		}

		public function get visible():Boolean {
			return node && node.visible;
		}

		public function get age():int {
			if(birthday){
				var d:Date = deathday ? deathday : Model.instance.currentDate;
				return (d.time - birthday.time) / (1000 * 60 * 60 * 24 * 365);
			}else
				return -1;
		}

		public function get editable():Boolean{
			return uid > 0 && open && _editable;
		}

		public function set editable(value:Boolean):void{
			_editable = value;
		}

		public function get hasBirthdayDate():Boolean{
			return birthday != null && !isNaN(birthday.time)
		}

		public function get hasDeathdayDate():Boolean{
			return deathday != null && !isNaN(deathday.time)
		}

		/**
		 * Установить дефолтные данные, после того, как с сервера присвоен uid
		 */
		public function assignDefaultData():void {
			urls.editUrl = "http://www.familyspace.ru/edit_profile/" + uid;
			urls.editPhotoUrl = "http://www.familyspace.ru/edit_profile/photo/" + uid;
			//urls.messageUrl = "http://www.familyspace.ru/messages/chat/18985299" + uid;
			urls.inviteUrl = "http://www.familyspace.ru/profile/invite/" + uid;
			profileUrl = "http://www.familyspace.ru/user" + uid;
		}
	}
}
