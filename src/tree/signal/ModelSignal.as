package tree.signal {
	public class ModelSignal {

		public static const NODES_NEED_CONSTRUCT:String = 'nodesNeedConstruct';
		public static const NODES_NEED_CALCULATE:String = 'nodesNeedCalculate';
		public static const NODES_RECALCULATED:String = 'nodesRecalculated';

		public static const SHOW_NODE:String = 'showNode';
		public static const HIDE_NODE:String = 'hideNode';
		public static const TREE_NEED_CONSTRUCT:String = 'treeNeedConstruct';

		public static const ADD_PERSON:String = 'addPerson';// join
		public static const REMOVE_PERSON:String = 'removePerson';// join
		public static const CHANGE_PERSON_JOINS:String = 'changePersonJoins';// person

		public function ModelSignal() {
		}
	}
}
