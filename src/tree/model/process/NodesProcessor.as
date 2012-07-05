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
		private var initialized:Boolean = false;

		private var queuedUids:Array;
		private var neighbours:Array;
		private var response:NodesProcessorResponse;
		private var forCallback:Array;

		/**
		 * Пропускать братьев-сестер, если есть родители
		 */
		protected var skipBroIfParents:Boolean = false;

		public function NodesProcessor(model:Model, start:Person, callback:Function) {
			this.model = model;
			this.current = start;
			this.callback = callback;
		}

		/**
		 * возвращает false, если процесс завершен
		 */
		public function process():Boolean {
			if(!initialized)
			{
				queuedUids = [];
				neighbours = [];
				forCallback = [];
				response = new NodesProcessorResponse();

				var ownerNode:Node = model.nodes.get(current.uid + '');

				response.node = ownerNode;
				response.source = null;
				response.fromSource = null;
				forCallback.push([ownerNode]);
				neighbours.push(current)
				queuedUids[ownerNode.uid] = true;

				initialized = true;
				return true;
			}else{

				while(forCallback.length)
				{
					var arr:Array = forCallback.shift();
					response.node = arr[0];
					response.source = arr[1]
					response.fromSource = arr[2];
					callback(response);
				}

				var p:Person
				if(neighbours.length){
					var newNeighbours:Array = recalculateNeighbours(neighbours.shift());
					for each(p in newNeighbours)
						neighbours.push(p);
				}

				return forCallback.length || neighbours.length;
			}
		}

		protected function recalculateNeighbours(owner:Person):Array {
			var nodes:NodesCollection = model.nodes;
			var ownerNode:Node = nodes.get(owner.uid + '');

			var newNeighbours:Array = [];

			var hasParents:Boolean = false;
			if(skipBroIfParents)
				hasParents = owner.parents.length > 0;

			for each(var join:Join in sortJoins(owner.joins))
				if(!queuedUids[join.uid])
				{
					if(hasParents && join.type.superType == JoinType.SUPER_TYPE_BRO)
						continue;

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
