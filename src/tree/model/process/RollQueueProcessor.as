package tree.model.process {
	import tree.model.Join;
	import tree.model.Model;
	import tree.model.Person;

	public class RollQueueProcessor extends SortedNodeProcessor{

		private var resultCallback:Function;
		private var result:Array = [];
		private var nodesUidsQueue:Array = [];

		/**
		 * @param model
		 * @param person
		 * @param resultCallback(queue:Array):void
		 */
		public function RollQueueProcessor(model:Model, person:Person, resultCallback:Function) {
			this.resultCallback = resultCallback;
			super(model, person, innerCallback);

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

			resultCallback(result);
		}

		private function innerCallback(response:NodesProcessorResponse):void {
			if(nodesUidsQueue[response.node.uid])
				result.push(response.fromSource);
		}
	}
}
