package tree.command.view {
	import tree.command.*;
	import tree.common.Config;
	import tree.manager.Ticker;
	import tree.model.Join;
	import tree.model.JoinType;
	import tree.model.Node;
	import tree.model.NodesCollection;
	import tree.model.Person;
	import tree.signal.ViewSignal;

	/**
	 * Продолжить построение дерева
	 */
	public class ContinueTreeDraw extends Command{
		public function ContinueTreeDraw() {
		}

		override public function execute():void {
			var startX:int;
			var j:Join;
			var n:Node;
			var p:Person;
			var join:Join = model.joinsForDraw.shift();
			if(!join)
			{
				// todo: постреение накончена, что нить задиспатчить
				return;
			}
			model.drawedJoins.push(join);

			var source:Person = join.from;
			var sourceNode:Node;
			var nodes:NodesCollection = model.nodes;
			if(source)
				sourceNode = source.node;

			var person:Person = join.associate;
			var node:Node = model.nodes.get(person.uid + '');

			switch(join.type ? join.type.superType : null) {
				case JoinType.SUPER_TYPE_MARRY:
					node.x = sourceNode.x + (join.type == Join.WIFE ? 1 : -1);
					node.y = sourceNode.y;
					break;
				case JoinType.SUPER_TYPE_BREED:
					node.y = sourceNode.y + 1;
					// выровнять в соответствии с кол-вом детей
					var breeds:Array = source.breeds;
					startX = source.male ? sourceNode.x + 0.5 : sourceNode.x - 0.5;
					// надо передвинуть остальных детей
					for each(p in source.breeds) {
						n = p.node;
						n.x = startX;
						n.fireChange();
						startX++;
					}
					node.x = startX;
					break;
				case JoinType.SUPER_TYPE_PARENT:
					node.y = sourceNode.y - 1;
					var parents:Array = sourceNode.parents;
					if(parents.length == 0)
						node.x = sourceNode.x;
					else
					{
						node.x = sourceNode.x + 0.5 * (person.male ? -1 : 1);
						j = parents[0]
						p = j.associate;
						n = p.node;
						n.x = sourceNode.x + 0.5 * (p.male ? -1 : 1);
						n.fireChange();
					}
					break;
				case JoinType.SUPER_TYPE_BRO:
					var bros:Array = sourceNode.bros;
					if(sourceNode.marry) {
						if(bros.length) n = bros[bros.length - 1] else n = node;
						node.x = n.x + (person.male ? -1 : 1);
					} else {
						// todo: построить в порядке рождения
						if(bros.length) n = bros[bros.length - 1] else n = node;
						node.x = n.x + (person.male ? -1 : 1);
					}
					node.y = sourceNode.y;
					break;
				case JoinType.SUPER_TYPE_EX_MARRY:
					node.x = sourceNode.x + 10;
					node.y = sourceNode.y;
					break;
				default:
					if(source)
						throw new Error('Undefined join super type');

					// мы имеем перво с самой первой нодой дерева (относительно которой строится всё дерево)
					node.x = 0;
					node.y = 0;
			}

			// добавляем в Generation
			model.generations.get(node.generation).addWithJoin(node, join);

			bus.dispatch(ViewSignal.DRAW_JOIN, join, node, person, sourceNode, source);
		}
	}
}
