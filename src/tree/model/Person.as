package tree.model {
	import org.osflash.signals.ISignal;

	import tree.Tree;

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
		public function photo(size:int = 0):String{
			if(size == 0){
				return photoSmall ? photoSmall : photoBig;
			}else if(size == 1){
				return photoBig ? photoBig : photoSmall;
			}
			return null;
		}

		public var tree:TreeModel;

		public var firstName:String = '';
		public var lastName:String = '';
		public var middleName:String = '';
		public var maidenName:String;
		public var birthday:Date = new Date();
		public var deathday:Date;
		public var email:String;
		public var post:String;
		public var profileUrl:String;

		public var homePlace:String;
		public var birthPlace:String;

		public var urls:Urls = new Urls();

		public  var open:Boolean = true;

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
			return lastName || firstName ? lastName + ' ' + firstName : uid.toString();
		}

		public function get fullname():String {
			return (lastName || firstName || middleName) ? lastName + ' ' + firstName + ' ' + middleName : uid.toString();
		}

		public function get died():Boolean{
			return open && deathday != null && !isNaN(deathday.date);
		}

		public function set died(value:Boolean):void{
			deathday = value ? new Date() : null;
		}

		public function get readonly():Boolean{
			return false;
		}

		public function get visible():Boolean {
			return node && node.visible;
		}

		public function get isNew():Boolean{
			return !node
		}

		public function get age():int {
			if(birthday){
				var d:Date = deathday ? deathday : Model.instance.currentDate;
				return (d.time - birthday.time) / (1000 * 60 * 60 * 24 * 365);
			}else
				return -1;
		}

		public function get editable():Boolean{
			return open && urls.editUrl != null;
		}
	}
}
