package tree.model {
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
		public var uid:int;
		public var from:Person;

		private var persons:PersonsCollection;

		public function Join(persons:PersonsCollection) {
			this.persons = persons;
		}

		override public function get id():String {
			return uid + "";
		}

		public function get associate():Person {
			return persons ? persons.get(uid + '') : null;
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

		public static function initializeConstants():void {
			// инициализируем типы
			FATHER = new JoinType(1, 'father', JoinType.SUPER_TYPE_PARENT, 40);
			FATHER.manAssoc = true;
			FATHER.flatten = false;
			FATHER.breed = false;

			MOTHER = new JoinType(2, 'mother', JoinType.SUPER_TYPE_PARENT, 40);
			MOTHER.manAssoc = false;
			MOTHER.flatten = false;
			MOTHER.breed = false;

			BROTHER = new JoinType(3, 'brother', JoinType.SUPER_TYPE_BRO, 20);
			BROTHER.manAssoc = true;
			BROTHER.flatten = true;
			BROTHER.breed = false;

			SISTER = new JoinType(4, 'sister', JoinType.SUPER_TYPE_BRO, 20);
			SISTER.manAssoc = false;
			SISTER.flatten = true;
			SISTER.breed = false;

			SON = new JoinType(5, 'son', JoinType.SUPER_TYPE_BREED, 80);
			SON.manAssoc = true;
			SON.flatten = false;
			SON.breed = true;

			DAUGHTER = new JoinType(6, 'daughter', JoinType.SUPER_TYPE_BREED, 80);
			DAUGHTER.manAssoc = false;
			DAUGHTER.flatten = false;
			DAUGHTER.breed = true;

			HUSBAND = new JoinType(7, 'husband', JoinType.SUPER_TYPE_MARRY, 100);
			HUSBAND.manAssoc = true;
			HUSBAND.flatten = true;
			HUSBAND.breed = false;

			WIFE = new JoinType(8, 'wife', JoinType.SUPER_TYPE_MARRY, 100);
			WIFE.manAssoc = false;
			WIFE.flatten = true;
			WIFE.breed = false;

			EX_HUSBAND = new JoinType(9, 'ex_husband', JoinType.SUPER_TYPE_EX_MARRY, -100);
			EX_HUSBAND.manAssoc = true;
			EX_HUSBAND.flatten = true;
			EX_HUSBAND.breed = false;

			EX_WIFE = new JoinType(10, 'ex_wife', JoinType.SUPER_TYPE_EX_MARRY, -100);
			EX_WIFE.manAssoc = false;
			EX_WIFE.flatten = true;
			EX_WIFE.breed = false;

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
			_serverToType[FATHER.name] 		= _serverToType[1] 	= FATHER;
			_serverToType[MOTHER.name] 		= _serverToType[2] 	= MOTHER;
			_serverToType[BROTHER.name] 	= _serverToType[3] 	= BROTHER;
			_serverToType[SISTER.name] 		= _serverToType[4] 	= SISTER;
			_serverToType[SON.name] 		= _serverToType[5] 	= SON;
			_serverToType[DAUGHTER.name] 	= _serverToType[6] 	= DAUGHTER;
			_serverToType[HUSBAND.name] 	= _serverToType[7] 	= HUSBAND;
			_serverToType[WIFE.name] 		= _serverToType[8] 	= WIFE;
			_serverToType[EX_HUSBAND.name] 	= _serverToType[9] 	= EX_HUSBAND;
			_serverToType[EX_WIFE.name] 	= _serverToType[10] = EX_WIFE;

			_typeToServer = [];
			_typeToServer[FATHER] = 1;
			_typeToServer[MOTHER] = 2;
			_typeToServer[BROTHER] = 3;
			_typeToServer[SISTER] = 4;
			_typeToServer[SON] = 5;
			_typeToServer[DAUGHTER] = 6;
			_typeToServer[HUSBAND] = 7;
			_typeToServer[WIFE] = 8;
			_typeToServer[EX_HUSBAND] = 9;
			_typeToServer[EX_WIFE] = 10;
		}

		public function toString():String {
			return from + ' is ' + type + ' of ' + associate;
		}
	}
}
