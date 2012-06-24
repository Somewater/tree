package tree.model {
	import tree.model.base.IModel;

	/**
	 * Связь между людьми. Всегда должна быть в 2-х экземплярах (двунаправленная связь)
	 * Уникальным id является id персоны, на которую ссылаются
	 */
	public class Join implements IModel{

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

		public static const FATHER:int = 		16;// 	1	(0000 100) - биты задом наперед (нулевой слева)
		public static const MOTHER:int = 		1;// 	2	(1000 000)

		public static const BROTHER:int = 		50;// 	3   (0100 110)
		public static const SISTER:int = 		35;// 	4   (1100 010)

		public static const SON:int = 			84;// 	5   (0010 101)
		public static const DAUGHTER:int = 		69;// 	6   (1010 001)

		public static const HUSBAND:int = 		54;// 	7   (0110 110)
		public static const WIFE:int = 			39;// 	8   (1110 010)

		public static const EX_HUSBAND:int = 	56;// 	9   (0001 110)
		public static const EX_WIFE:int = 		41;// 	10  (1001 010)

		private static const FLAG_MALE:int = 16;
		private static const FLAG_FLATTEN:int = 32;
		private static const FLAG_BREED:int = 64;
		private static const FLAG_I_AM_MAN:int = 512;

		private static var _serverToType:Array;
		private static var _typeToServer:Array;
		private static var _typeToAlter:Array;
		private static var _typeToString:Array;

		public var type:int;
		public var uid:int;
		public var owner:Person;

		private var persons:PersonsCollection;

		public function Join(persons:PersonsCollection) {
			this.persons = persons;
		}

		public function get id():String {
			return uid + "";
		}

		public function get associate():Person {
			return persons.get(uid + '');
		}

		public function get flatten():Boolean {
			return (type & FLAG_FLATTEN) != 0
		}

		public function get breed():Boolean {
			return (type & FLAG_BREED) != 0;
		}

		public static function serverToType(serverType:int):int {
			return _serverToType[serverType];
		}

		public static function typeToServer(type:int):int {
			return _typeToServer[type];
		}

		public static function toAlter(type:int, iAmMan:Boolean):int {
			return _typeToAlter[type | (iAmMan ? FLAG_I_AM_MAN : 0)];
		}

		public static function initializeConstants():void {
			_serverToType = [];
			_serverToType[1] = FATHER;
			_serverToType[2] = MOTHER;
			_serverToType[3] = BROTHER;
			_serverToType[4] = SISTER;
			_serverToType[5] = SON;
			_serverToType[6] = DAUGHTER;
			_serverToType[7] = HUSBAND;
			_serverToType[8] = WIFE;
			_serverToType[9] = EX_HUSBAND;
			_serverToType[10] = EX_WIFE;

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

			_typeToAlter = [];

			_typeToAlter[FATHER | FLAG_I_AM_MAN] = SON;
			_typeToAlter[FATHER] = DAUGHTER;

			_typeToAlter[MOTHER | FLAG_I_AM_MAN] = SON;
			_typeToAlter[MOTHER] = DAUGHTER;

			_typeToAlter[BROTHER | FLAG_I_AM_MAN] = BROTHER;
			_typeToAlter[BROTHER] = SISTER;

			_typeToAlter[SISTER | FLAG_I_AM_MAN] = BROTHER;
			_typeToAlter[SISTER] = SISTER;

			_typeToAlter[SON | FLAG_I_AM_MAN] = FATHER;
			_typeToAlter[SON] = MOTHER;

			_typeToAlter[DAUGHTER | FLAG_I_AM_MAN] = FATHER;
			_typeToAlter[DAUGHTER] = MOTHER;

			_typeToAlter[HUSBAND | FLAG_I_AM_MAN] = WIFE;// gomo
			_typeToAlter[HUSBAND] = WIFE;

			_typeToAlter[WIFE | FLAG_I_AM_MAN] = HUSBAND;
			_typeToAlter[WIFE] = HUSBAND;// gomo

			_typeToAlter[EX_HUSBAND | FLAG_I_AM_MAN] = EX_WIFE;// gomo
			_typeToAlter[EX_HUSBAND] = EX_WIFE;

			_typeToAlter[EX_WIFE | FLAG_I_AM_MAN] = EX_HUSBAND;
			_typeToAlter[EX_WIFE] = EX_HUSBAND;// gomo

			_typeToString = [];
			_typeToString[FATHER] = 'father';
			_typeToString[MOTHER] = 'mother';
			_typeToString[BROTHER] = 'brother';
			_typeToString[SISTER] = 'sister';
			_typeToString[SON] = 'son';
			_typeToString[DAUGHTER] = 'daughter';
			_typeToString[HUSBAND] = 'husband';
			_typeToString[WIFE] = 'wife';
			_typeToString[EX_HUSBAND] = 'ex_husband';
			_typeToString[EX_WIFE] = 'ex_wife';
		}

		public function toString():String {
			return owner + ' is ' + _typeToString[type] + ' of ' + associate;
		}
	}
}
