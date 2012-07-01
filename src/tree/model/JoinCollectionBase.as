package tree.model {
	import tree.model.base.ICollection;
	import tree.model.base.ModelCollection;

	public class JoinCollectionBase extends ModelCollection implements ICollection{

		private var _marryCalculated:Boolean = false;
		private var _marry:Person;
		private var _ex_marries:Array;
		private var _breeds:Array;
		private var _parents:Array;
		private var _bros:Array;

		protected var useJoinsCache:Boolean = true;

		public function JoinCollectionBase() {
		}

		public function get marry():Person {
			if(!useJoinsCache || !_marryCalculated) {
				for each(var j:Join in array)
					if(j.type.superType == JoinType.SUPER_TYPE_MARRY) {
						_marry = j.associate;
						break;
					}
				_marryCalculated = true;
			}
			return _marry;
		}

		public function get ex_marries():Array {
			if(!useJoinsCache || !_ex_marries) {
				_ex_marries = [];
				for each(var j:Join in array)
					if(j.type.superType == JoinType.SUPER_TYPE_EX_MARRY)
						_ex_marries.push(j.associate);
			}
			return _ex_marries;
		}

		public function get breeds():Array {
			if(!useJoinsCache || !_breeds) {
				_breeds = [];
				for each(var j:Join in array)
					if(j.type.superType == JoinType.SUPER_TYPE_BREED)
						_breeds.push(j.associate);
			}
			return _breeds;
		}

		public function get parents():Array {
			if(!useJoinsCache || !_parents) {
				_parents = []
				for each(var j:Join in array)
					if(j.type.superType == JoinType.SUPER_TYPE_PARENT)
						_parents.push(j.associate);
			}
			return _parents;
		}

		public function get bros():Array {
			if(!useJoinsCache || !_bros) {
				_bros = []
				for each(var j:Join in array)
					if(j.type.superType == JoinType.SUPER_TYPE_BRO)
						_bros.push(j.associate);
			}
			return _bros;
		}
	}
}
