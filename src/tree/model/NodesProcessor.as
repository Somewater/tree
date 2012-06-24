package tree.model {

	/**
	 * Итеративно обрабатывает всех родственников, последвательно распространяя обработку (с увеличением пар-ра "d")ё
	 */
	public class NodesProcessor {

		private var currentPosition:Person;
		private var model:Model;

		private var processedUids:Array;
		private var queuedUids:Array;
		private var neighbours:Array;

		private var callback:Function;
		private var forCallback:Array;

		private var callbackArg:NodesProcessorCallback;

		public function NodesProcessor(owner:Person, model:Model, callback:Function) {
			currentPosition = owner;
			this.model = model;
			this.callback = callback;
		}


		public function start():void
		{
			processedUids = [];
			queuedUids = [];
			neighbours = [];
			processedUids[currentPosition.uid] = true;
			neighbours = [currentPosition];
			forCallback = [ [model.nodes.get(currentPosition.uid + ''), null] ];
			callbackArg = new NodesProcessorCallback();
		}

		public function tick():void {
			var p:Person;

			while(forCallback.length)
			{
				var arr:Array = forCallback.shift();
				callbackArg.current = arr[0];
				callbackArg.relativeJoin = arr[1]
				callbackArg.relative = arr[2];
				callback(callbackArg);
			}

			if(neighbours.length){
				var newNeighbours:Array = recalculateNeighbours(neighbours.pop());
				for each(p in newNeighbours)
					neighbours.push(p);
			} else {
				callback(null);
			}
		}

		private function recalculateNeighbours(owner:Person):Array {
			var neighbours:Array = [];
			var nodes:NodesCollection = model.nodes;
			var ownerNode:Node = nodes.get(owner.uid + '');

			for each(var join:Join in sortedJoins(owner.joins))
				if(!processedUids[join.uid])// не считаем дваджы во измежании циклов
				{
					var assoc:Person = join.associate;
					var assocNode:Node = nodes.get(assoc.uid + '');

					forCallback.push([assocNode, join, ownerNode]);
					processedUids[join.uid] = true;

					// ассоциированных с этим человеком родственников добавлям к рассчету
					for each(var join2:Join in assoc.joins)
						if(!processedUids[join2.uid] && !queuedUids[join2.uid])
						{
							neighbours.push(join2.associate);
							queuedUids[join2.uid] = true;
						}
				}

			return neighbours;
		}

		protected function sortedJoins(joins:Array):Array {
			return joins;
		}
	}
}
