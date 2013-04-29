package tree.command.view {
import com.junkbyte.console.Cc;

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

		private var queueForRollUnrollRefresh:Array = []; // array of node

		public function CalculateNextNodeRollUnroll() {
			if(tick == null)
				tick = new Tick();
		}

		override public function execute():void {
			joins = model.joinsQueue.slice().filter(function(j:Join,...args):Boolean{
				return j.associate.node != null;
			});

			tick.command = this;
			tick.start();
			detain()
		}

		public function calculate():int{
			if(index < joins.length){
				var join:Join = joins[index];
				new RollQueueProcessor(join.associate.tree, join.associate, onCalculated);
				return 3;
			}else{
				if(queueForRollUnrollRefresh.length > 0){
					model.rollUnrollAvailable = true;
					var n:Node = queueForRollUnrollRefresh.shift();
					n.fireRollChange();
					return 1
				}else{
					tick.stop();
					release();
					return 1000;
				}
			}
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
			queueForRollUnrollRefresh.push(join.associate.node);//join.associate.node.fireRollChange();

			index++;
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
	private var active:Boolean = false;

	public function tick(deltaMS:int):void {
		var i:int = 10;
		while( i >= 0 && active)
			i -= command.calculate();
	}

	public function start():void{
		active = true;
		Config.ticker.add(this);
	}

	public function stop():void{
		active = false;
		Config.ticker.remove(this);
		command = null;
	}
}
