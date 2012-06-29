package tree.model.process {
	import tree.model.Join;
	import tree.model.Model;
	import tree.model.Person;

	/**
	 * Сортирует родственников в соответствии с правилами очередности отображения
	 */
	public class SortedNodeProcessor extends NodesProcessor{

		public function SortedNodeProcessor(model:Model, start:Person, callback:Function) {
			super(model, start, callback);
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
				return j1.type - j2.type;
			})
			return joins;
		}
	}
}
