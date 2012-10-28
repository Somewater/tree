package tree.model {
	import com.somewater.storage.I18n;

	import flash.utils.Dictionary;

	import tree.model.base.IModel;

	/**
	 * Связь между людьми. Всегда должна быть в 2-х экземплярах (двунаправленная связь)
	 * Уникальным id является id персоны, на которую ссылаются
	 */
	public class Join extends ModelBase implements IModel{

		/**
		 * Применяем маску байт, где
		 *
		 * порядковый номер
		 * |______
		 * | | | |
		 * v v v v
		 * 0 1 2 3 4 5 6 7 8 9 ...
		 *         ^ ^ ^ ^ ^ ^
		 *         | | | | | |
		 *         | | |     iAmMan flag
		 *         | | |
		 *         | | нисходящая (true) или восходящая (потомство - это нисходящая), если флаг бита [1] выставлен, не имеет смысла
		 *         | |
		 *         | тот же уровень (true) - т.е. не родители и не потомство
		 *         |
		 *         мужчина (true) или женщина, т.е. реципиент связи мужчина
 		 */

		public static var FATHER:JoinType;// 	1	(0000 100) - биты задом наперед (нулевой слева)
		public static var MOTHER:JoinType;// 	2	(1000 000)

		public static var BROTHER:JoinType;// 	3   (0100 110)
		public static var SISTER:JoinType;// 	4   (1100 010)

		public static var SON:JoinType;// 	5   (0010 101)
		public static var DAUGHTER:JoinType;// 	6   (1010 001)

		public static var HUSBAND:JoinType;// 	7   (0110 110)
		public static var WIFE:JoinType;// 	8   (1110 010)

		public static var EX_HUSBAND:JoinType;// 	9   (0001 110)
		public static var EX_WIFE:JoinType;// 	10  (1001 010)

		private static var _serverToType:Array;
		private static var _typeToServer:Array;

		public var type:JoinType;
		public var associate:Person;
		public var from:Person;

		public var visible:Boolean = false;

		private var persons:PersonsCollection;

		public function Join(persons:PersonsCollection) {
			this.persons = persons;
		}

		override public function get id():String {
			return uid + "";
		}

		private var _uniqId:String;
		public function get uniqId():String{
			if(!_uniqId) {
				var arr:Array = [this.uid];
				if(from)
					arr.push(from.uid);
				arr.sort(Array.NUMERIC);
				_uniqId = arr.join('~>');
			}
			return _uniqId;
		}

		public function get uid():int {
			return associate.uid;
		}

		public function get flatten():Boolean {
			return type.flatten
		}

		public function get breed():Boolean {
			return type.breed
		}

		public static function serverToType(serverType:String):JoinType {
			return _serverToType[serverType];
		}

		public static function typeToServer(type:JoinType):int {
			return _typeToServer[type];
		}

		public static function toAlter(type:JoinType, iAmMan:Boolean):JoinType {
			if(iAmMan)
				return type.associatedTypeForMale;
			else
				return type.associatedTypeForFemale;
		}

		public static function toEx(type:JoinType):JoinType {
			if(type == HUSBAND)
				return EX_HUSBAND;
			else if(type == WIFE)
				return EX_WIFE;
			throw new Error('Type ' + type + ' has not ex synonim');
		}

		public static function initializeConstants():void {
			// инициализируем типы
			FATHER = new JoinType(1, 'father', JoinType.SUPER_TYPE_PARENT, 40);
			FATHER.manAssoc = true;
			FATHER.flatten = false;
			FATHER.breed = false;
			FATHER.vector = 0;

			MOTHER = new JoinType(2, 'mother', JoinType.SUPER_TYPE_PARENT, 40);
			MOTHER.manAssoc = false;
			MOTHER.flatten = false;
			MOTHER.breed = false;
			MOTHER.vector = 1;

			BROTHER = new JoinType(3, 'brother', JoinType.SUPER_TYPE_BRO, 20);
			BROTHER.manAssoc = true;
			BROTHER.flatten = true;
			BROTHER.breed = false;
			BROTHER.vector = 0;

			SISTER = new JoinType(4, 'sister', JoinType.SUPER_TYPE_BRO, 20);
			SISTER.manAssoc = false;
			SISTER.flatten = true;
			SISTER.breed = false;
			SISTER.vector = 0;

			SON = new JoinType(5, 'son', JoinType.SUPER_TYPE_BREED, 80);
			SON.manAssoc = true;
			SON.flatten = false;
			SON.breed = true;
			SON.vector = 0;

			DAUGHTER = new JoinType(6, 'daughter', JoinType.SUPER_TYPE_BREED, 80);
			DAUGHTER.manAssoc = false;
			DAUGHTER.flatten = false;
			DAUGHTER.breed = true;
			DAUGHTER.vector = 0;

			HUSBAND = new JoinType(7, 'husband', JoinType.SUPER_TYPE_MARRY, 1000000);
			HUSBAND.manAssoc = true;
			HUSBAND.flatten = true;
			HUSBAND.breed = false;
			HUSBAND.vector = -1;

			WIFE = new JoinType(8, 'wife', JoinType.SUPER_TYPE_MARRY, 1000000);
			WIFE.manAssoc = false;
			WIFE.flatten = true;
			WIFE.breed = false;
			WIFE.vector = 1;

			EX_HUSBAND = new JoinType(9, 'ex_husband', JoinType.SUPER_TYPE_EX_MARRY, -100);
			EX_HUSBAND.manAssoc = true;
			EX_HUSBAND.flatten = true;
			EX_HUSBAND.breed = false;
			EX_HUSBAND.vector = -1;

			EX_WIFE = new JoinType(10, 'ex_wife', JoinType.SUPER_TYPE_EX_MARRY, -100);
			EX_WIFE.manAssoc = false;
			EX_WIFE.flatten = true;
			EX_WIFE.breed = false;
			EX_WIFE.vector = 1;

			// связываем
			FATHER.associatedTypeForMale = SON;
			FATHER.associatedTypeForFemale = DAUGHTER;

			MOTHER.associatedTypeForMale = SON;
			MOTHER.associatedTypeForFemale = DAUGHTER;

			BROTHER.associatedTypeForMale = BROTHER;
			BROTHER.associatedTypeForFemale = SISTER;

			SISTER.associatedTypeForMale = BROTHER;
			SISTER.associatedTypeForFemale = SISTER;

			SON.associatedTypeForMale = FATHER;
			SON.associatedTypeForFemale = MOTHER;

			DAUGHTER.associatedTypeForMale = FATHER;
			DAUGHTER.associatedTypeForFemale = MOTHER;

			HUSBAND.associatedTypeForMale = null;
			HUSBAND.associatedTypeForFemale = WIFE;

			WIFE.associatedTypeForMale = HUSBAND;
			WIFE.associatedTypeForFemale = null;

			EX_HUSBAND.associatedTypeForMale = null;
			EX_HUSBAND.associatedTypeForFemale = EX_WIFE;

			EX_WIFE.associatedTypeForMale = EX_HUSBAND;
			EX_WIFE.associatedTypeForFemale = null;

			_serverToType = [];
			_typeToServer = [];

			configurateServerType(FATHER, 1);
			configurateServerType(MOTHER, 2);
			configurateServerType(BROTHER, 3);
			configurateServerType(SISTER, 4);
			configurateServerType(SON, 5);
			configurateServerType(DAUGHTER, 6);
			configurateServerType(HUSBAND, 7);
			configurateServerType(WIFE, 8);
			configurateServerType(EX_HUSBAND, 9);
			configurateServerType(EX_WIFE, 10);

			function configurateServerType(type:JoinType, server:int):void{
				_serverToType[server] = type;
				_serverToType[type.name] = type;
				_typeToServer[type] = server;
			}
		}

		public function toString():String {
			return associate + ' is ' + type + ' of ' + from;
		}

		public function get name():String {
			return type.name;
		}

		public function toLocaleString(_case:String = null):String{
			return type.toLocaleString(_case);
		}

		public static function joinBy(superJoinType:String, targetMale:Boolean):JoinType{
			if(superJoinType == JoinType.SUPER_TYPE_BREED){
				return targetMale ? SON : SISTER;
			}else if(superJoinType == JoinType.SUPER_TYPE_BRO){
				return targetMale ? BROTHER : SISTER;
			}else if(superJoinType == JoinType.SUPER_TYPE_EX_MARRY){
				return targetMale ? EX_HUSBAND : EX_WIFE;
			}else if(superJoinType == JoinType.SUPER_TYPE_MARRY){
				return targetMale ? HUSBAND : WIFE;
			}else if(superJoinType == JoinType.SUPER_TYPE_PARENT){
				return targetMale ? FATHER : MOTHER;
			}
			throw new Error('Undefined combination');
		}
	}
}
