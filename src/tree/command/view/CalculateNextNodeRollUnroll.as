package tree.command.view {
	import tree.command.Command;
	import tree.common.Config;
	import tree.model.Join;
	import tree.model.Node;
	import tree.model.process.RollQueueProcessor;
	import tree.view.canvas.INodeViewCollection;

	/**
	 * Калькулирует очередную ноду, может ли на ней отображаться кнопка roll-unroll
	 */
	public class CalculateNextNodeRollUnroll extends Command{

		public static var tick:Tick;

		private var joins:Array;
		private var index:int = 0;

		public function CalculateNextNodeRollUnroll() {
			if(tick == null)
				tick = new Tick();
		}

		override public function execute():void {
			joins = model.joinsQueue.slice();

			tick.command = this;
			tick.start();
			detain()
		}

		public function calculate():void{
			var join:Join = joins[index];
			new RollQueueProcessor(join.associate.tree, join.associate, onCalculated);
		}

		private function onCalculated(array:Array):void{
			var join:Join = joins[index];
			var node:Node = join.associate.node;
			if(array.length){
				var slaves:Array = joinsToNodes(array);
				join.associate.node.slaves = slaves
				for each(var n:Node in slaves){
					if(!n.lords) n.lords = [];
					n.lords.push(node);
				}
			}else
				join.associate.node.slaves = Node.EMPTY_ROLL;
			join.associate.node.fireRollChange();

			index++;
			if(index >= joins.length){
				tick.stop();
				release();
			}
		}

		private function joinsToNodes(joins:Array):Array{
			var nodes:Array = [];
			for each(var j:Join in joins)
				nodes.push(j.associate.node);
			return nodes;
		}
	}
}

import tree.command.view.CalculateNextNodeRollUnroll;
import tree.common.Config;
import tree.manager.ITick;

class Tick implements ITick{

	public var command:CalculateNextNodeRollUnroll;

	public function tick(deltaMS:int):void {
		command.calculate();
	}

	public function start():void{
		Config.ticker.add(this);
	}

	public function stop():void{
		Config.ticker.remove(this);
		command = null;
	}
}
