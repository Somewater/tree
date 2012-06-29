package tree.model {
	public class JoinType {

		public var manAssoc:Boolean;// мужчина (true) или женщина, т.е. реципиент связи мужчина
		public var flatten:Boolean;// тот же уровень (true) - т.е. не родители и не потомство
		public var breed:Boolean;// нисходящая (true) или восходящая (потомство - это нисходящая), если флаг бита [1] выставлен, не имеет смысла

		public var associatedType:JoinType;

		public function JoinType() {
		}
	}
}
