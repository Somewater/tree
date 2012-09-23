package tree.model {
	import com.somewater.storage.I18n;

	public class JoinType {

		public static var SUPER_TYPE_PARENT:String = 'parent';
		public static var SUPER_TYPE_BREED:String = 'breed';
		public static var SUPER_TYPE_BRO:String = 'bro';
		public static var SUPER_TYPE_MARRY:String = 'marry';
		public static var SUPER_TYPE_EX_MARRY:String = 'ex_marry';

		public var id:int;

		public var manAssoc:Boolean;// мужчина (true) или женщина, т.е. реципиент связи мужчина
		public var flatten:Boolean;// тот же уровень (true) - т.е. не родители и не потомство
		public var breed:Boolean;// нисходящая (true) или восходящая (потомство - это нисходящая), если флаг бита [1] выставлен, не имеет смысла

		public var associatedTypeForMale:JoinType;
		public var associatedTypeForFemale:JoinType;

		public var name:String
		public var superType:String;
		public var priority:int
		public var vector:int;

		public function JoinType(id:int, name:String, superType:String, priority:int) {
			this.id = id;
			this.name = name;
			this.superType = superType;
			this.priority = priority;
		}

		public function toString():String {
			return name;
		}

		public function toLocaleString(_case:String = null):String{
			return I18n.t(name.toUpperCase() + (_case ? '_' + _case.toUpperCase() : ''));
		}

		public static var FIRST_JOIN:JoinType = new JoinType(0, 'start', null, int.MAX_VALUE - 1000000);
	}
}
