package tree.command.view {
	import tree.command.*;
	import tree.common.Config;
	import tree.manager.Ticker;
	import tree.model.GenNode;
	import tree.model.Join;
	import tree.model.JoinType;
	import tree.model.Node;
	import tree.model.NodesCollection;
	import tree.model.Person;
	import tree.model.SpatialMatrix;
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
				log('Дерево построено. ' + model.drawedJoins.length + ' вершин');
				return;
			}
			model.drawedJoins.push(join);

			calculateRelativePosition(join);

			var g:GenNode = model.generations.get(join.associate.node.generation).addWithJoin(join);

			// добавить в ноды связи друг на друга
			if(join.from) { // если это стартовая нода, то join.from == null
				join.from.node.add(join);
				join.associate.node.add(join.associate.get(join.from.uid + ''));
			}

			bus.dispatch(ViewSignal.DRAW_JOIN, g);
		}

		private function calculateRelativePosition(join:Join):void {
			var source:Person = join.from;
			var sourceNode:Node;
			if(source)
				sourceNode = source.node;

			var node:Node = join.associate.node;

			switch(join.type ? join.type.superType : null) {
				case JoinType.SUPER_TYPE_MARRY:
					node.x = sourceNode.x + (join.type == Join.WIFE ? 1 : -1);
					break;
				case JoinType.SUPER_TYPE_BREED:
					node.x = sourceNode.x;
					break;
				case JoinType.SUPER_TYPE_PARENT:
					node.x = sourceNode.x;
					break;
				case JoinType.SUPER_TYPE_BRO:
				case JoinType.SUPER_TYPE_EX_MARRY:
					node.x = sourceNode.x + (source.male ? -1 : 1);
					break;
				default:
					if(source)
						throw new Error('Undefined join super type');

					// мы имеем перво с самой первой нодой дерева (относительно которой строится всё дерево)
					node.x = 0;
			}
		}
	}
}
