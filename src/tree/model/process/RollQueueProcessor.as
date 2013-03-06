package tree.model.process {
	import tree.model.Join;
	import tree.model.Model;
	import tree.model.Node;
	import tree.model.Person;
	import tree.model.TreeModel;

	public class RollQueueProcessor extends SortedPersonsProcessor{

		private var resultCallback:Function;
		private var result:Array = [];

		private var node:Node;

		/**
		 * @param model
		 * @param person
		 * @param resultCallback(queue:Array of Join):void массив нод, которые построеные начиная от заданной
		 */
		public function RollQueueProcessor(tree:TreeModel, person:Person, resultCallback:Function) {
			this.resultCallback = resultCallback;
			this.node = person.node;
			super(tree, person, innerCallback);

			this.useNodeJoins = true;
			this.customCheck = checkJoin;

			while(this.process()){}

			result.shift();// избавляемся от первого элемента. т.к. он символизирует person и равен null
			resultCallback(result);
		}

		private function innerCallback(response:NodesProcessorResponse):void {
			if(response.node)
				result.push(response.fromSource);
		}

		private function checkJoin(join:Join):Boolean{
			return join.associate.node.dist > node.dist;
		}

		override protected function sortJoins(joins:Array):Array {
			return super.sortJoins(joins).filter(function(j:Join,...args):Boolean{
				return j.associate.node;
			});
		}
	}
}
