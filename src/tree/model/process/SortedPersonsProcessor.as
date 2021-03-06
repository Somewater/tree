package tree.model.process {
	import tree.model.Join;
	import tree.model.Model;
	import tree.model.Person;
	import tree.model.TreeModel;

	/**
	 * Сортирует родственников в соответствии с правилами очередности отображения
	 */
	public class SortedPersonsProcessor extends PersonsProcessor{

		public function SortedPersonsProcessor(tree:TreeModel, start:Person, callback:Function) {
			super(tree, start, callback);

			skipBroIfParents = true;
			skipIfMarry = true;
		}

		/**
		 * Сначала рисуется муж-жена,
		 * затем дети,
		 * затем родители,
		 * затем братья
		 * затем бывшие
		 */
		override protected function sortJoins(joins:Array):Array {
			joins = joins.slice();
			joins.sort(function(j1:Join, j2:Join):int{
				var delta:int = j2.type.priority - j1.type.priority;
				if(delta != 0)
					return delta;
				else {
					var j1male:Boolean = j1.associate.male;
					var j2male:Boolean = j2.associate.male;
					if(j1male && !j2male)
						return -1;
					else if(!j1male && j2male)
						return 1;
					else
						return j1.uid - j2.uid;
				}
			})
			return joins;
		}
	}
}
