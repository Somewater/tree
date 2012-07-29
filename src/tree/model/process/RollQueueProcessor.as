package tree.model.process {
	import tree.model.Join;
	import tree.model.Model;
	import tree.model.Node;
	import tree.model.Person;

	public class RollQueueProcessor extends SortedPersonsProcessor{

		private var resultCallback:Function;
		private var result:Array = [];
		private var nodesUidsQueue:Array = [];

		private var node:Node;

		/**
		 * @param model
		 * @param person
		 * @param resultCallback(queue:Array of Join):void массив нод, которые построеные начиная от заданной
		 */
		public function RollQueueProcessor(model:Model, person:Person, resultCallback:Function) {
			this.resultCallback = resultCallback;
			this.node = person.node;
			super(model, person, innerCallback);

			this.useNodeJoins = true;
			this.customCheck = checkJoin;

			nodesUidsQueue = [];
			var personDetected:Boolean = false;
			for each(var j:Join in model.joinsQueue)
				if(personDetected)
					nodesUidsQueue[j.uid] = true;
				else{
					if(j.uid == person.uid)
						personDetected = true
				}

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
	}
}
