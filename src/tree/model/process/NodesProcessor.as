package tree.model.process {
	import tree.model.*;
	import tree.common.*;
	import tree.model.Join;
	import tree.model.Model;
	import tree.model.Node;
	import tree.model.NodesCollection;
	import tree.model.Person;

	public class NodesProcessor {

		private var model:Model;
		private var current:Person;
		private var callback:Function;
		private var nodesConstructed:Boolean = false;

		private var queuedUids:Array;
		private var neighbours:Array;
		private var response:NodesProcessorResponse;
		private var forCallback:Array;

		public function NodesProcessor(model:Model, start:Person, callback:Function) {
			this.model = model;
			this.current = start;
			this.callback = callback;
		}

		/**
		 * возвращает false, если процесс завершен
		 */
		public function process():Boolean {
			if(!nodesConstructed)
			{
				nodesConstructed = true;
				var nodes:NodesCollection = model.nodes;
				nodes.clear();
				var node:Node;
				var p:Person;

				for each(p in model.persons.iterator)
				{
					node = nodes.get(p.uid.toString());
					if(node == null)
					{
						node = nodes.allocate(p);
						nodes.add(node);
					}
				}

				queuedUids = [];
				neighbours = [];
				forCallback = [];
				response = new NodesProcessorResponse();

				var ownerNode:Node = nodes.get(current.uid + '');

				response.node = ownerNode;
				response.parent = null;
				response.fromParent = null;
				forCallback.push([ownerNode]);
				neighbours.push(current)
				queuedUids[ownerNode.uid] = true;
				return true;
			}else{

				while(forCallback.length)
				{
					var arr:Array = forCallback.shift();
					response.node = arr[0];
					response.parent = arr[1]
					response.fromParent = arr[2];
					callback(response);
				}

				if(neighbours.length){
					var newNeighbours:Array = recalculateNeighbours(neighbours.shift());
					for each(p in newNeighbours)
						neighbours.push(p);
				}

				return forCallback.length || neighbours.length;
			}
		}

		private function recalculateNeighbours(owner:Person):Array {
			var nodes:NodesCollection = model.nodes;
			var ownerNode:Node = nodes.get(owner.uid + '');

			var newNeighbours:Array = [];

			for each(var join:Join in sortJoins(owner.joins))
				if(!queuedUids[join.uid])
				{
					var assoc:Person = join.associate;
					var assocNode:Node = nodes.get(assoc.uid + '');

					forCallback.push([assocNode, ownerNode, join]);

					// ассоциированных с этим человеком родственников добавлям к рассчету
					if(!queuedUids[assoc.uid])
					{
						newNeighbours.push(assoc);
						queuedUids[assoc.uid] = true;
					}
				}

			return newNeighbours;
		}

		protected function sortJoins(joins:Array):Array {
			return joins;
		}

		public function clear():void {
			model = null;
			current = null;
			callback = null;
			queuedUids = null;
			neighbours = null;
			response = null;
		}
	}
}
