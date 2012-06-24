package tree.model {
	import org.osflash.signals.ISignal;

	import tree.model.base.ICollection;
	import tree.model.base.IModel;
	import tree.model.base.ModelCollection;

	/**
	 * Модель человека. Одновременно, является коллекцией join
	 */
	public class Person extends ModelCollection implements IModel, ICollection{

		public var name:String;
		public var male:Boolean;
		public var uid:int;

		public function Person() {
		}

		public function get id():String {
			return uid + '';
		}

		public function get female():Boolean{return !male;}

		/**
		 * Проверяем, что добавляется Join, причем допустимая
		 * @param model
		 */
		override public function add(model:IModel):void {
			var join:Join = model as Join;
			if(join == null)
				throw new Error('Must be join only');
			super.add(model);
		}

		public function get(id:String):Join {
			return hash[id];
		}

		public function get joins():Array {
			return array;
		}

		public function toString():String {
			return '[' + this.name + ' ' + uid + ']';
		}
	}
}
