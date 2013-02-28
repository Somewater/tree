package tree.command.view {
import com.junkbyte.console.vos.Log;

import tree.command.Command;
import tree.manager.Logic;
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
			if(model.selectedPerson == null)
				model.selectedPerson = join.associate;
			if(model.selectedTree == null)
				model.selectedTree = join.associate.tree;

			model.drawedNodesUids[join.uid] = true;
			if(model.joinsQueue.indexOf(join) == -1) model.joinsQueue.push(join);

			Logic.calculateRelativePosition(join);
			if(join.from && !join.associate.node.handCoords){
				Logic.calculateRelativePosition(join, true);
				Logic.checkIntersections(join.associate.node);
			}

			var g:GenNode = model.generations.get(join.associate.node.generation).addWithJoin(join);

			// добавить в ноды связи друг на друга
			if(join.from) { // если это стартовая нода, то join.from == null
				join.from.node.add(join);
				join.associate.node.add(join.associate.get(join.from.uid + ''));
			}

			model.trees.refreshTreeSizes(g.node.person, true);

			bus.dispatch(ViewSignal.DRAW_JOIN, g);
		}
	}
}
