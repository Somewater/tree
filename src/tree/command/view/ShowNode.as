package tree.command.view {
	import tree.command.Command;
	import tree.model.GenNode;
	import tree.model.Join;
	import tree.model.JoinType;
	import tree.model.Node;
	import tree.model.Person;
	import tree.signal.ViewSignal;

	public class ShowNode extends Command{

		private var join:Join;

		public function ShowNode(join:Join) {
			this.join = join;
		}

		override public function execute():void {
			model.drawedNodesUids[join.uid] = true;

			calculateRelativePosition(join);

			var g:GenNode = model.generations.get(join.associate.node.generation).addWithJoin(join);

			// добавить в ноды связи друг на друга
			if(join.from) { // если это стартовая нода, то join.from == null
				join.from.node.add(join);
				join.associate.node.add(join.associate.get(join.from.uid + ''));
			}

			model.trees.refreshTreeSizes(g.node.person, true);

			bus.dispatch(ViewSignal.DRAW_JOIN, g);
		}

		private function calculateRelativePosition(join:Join):void {
			var source:Person = join.from;
			var sourceNode:Node;
			if(source)
				sourceNode = source.node;

			var node:Node = join.associate.node;
			var hasLegitimateBreed:Boolean;

			switch(join.type ? join.type.superType : null) {
				case JoinType.SUPER_TYPE_MARRY:
					node.x = sourceNode.x + (join.type == Join.WIFE ? 2 : -2);
					node.oddX = sourceNode.oddX;
					break;
				case JoinType.SUPER_TYPE_BREED:
					hasLegitimateBreed = sourceNode.person.hasLegitimateBreed()
					node.x = sourceNode.x + (hasLegitimateBreed ? (sourceNode.person.male ? 1 : -1) : 0);
					node.oddX = hasLegitimateBreed ? !sourceNode.oddX : sourceNode.oddX;
					break;
				case JoinType.SUPER_TYPE_PARENT:
					hasLegitimateBreed = node.person.hasLegitimateBreed()
					node.x = sourceNode.x + (hasLegitimateBreed ? (node.person.male ? -1 : 1) : 0);
					node.oddX = hasLegitimateBreed ? !sourceNode.oddX : sourceNode.oddX;
					break;
				case JoinType.SUPER_TYPE_BRO:
				case JoinType.SUPER_TYPE_EX_MARRY:
					node.x = sourceNode.x + (source.male ? -2 : 2);
					node.oddX = sourceNode.oddX;
					break;
				default:
					if(source)
						throw new Error('Undefined join super type');

					// мы имеем перво с самой первой нодой дерева (относительно которой строится всё дерево)
					node.x = 0;
					node.oddX = true;
			}
		}
	}
}
