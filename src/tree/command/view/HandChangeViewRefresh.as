package tree.command.view {
import flash.geom.Point;

import tree.command.Command;
import tree.command.RecalculateNodes;
import tree.manager.Logic;
import tree.model.GenNode;
import tree.model.Generation;
import tree.model.ModelBase;
import tree.model.Node;
import tree.model.Person;
import tree.model.TreeModel;
import tree.signal.ViewSignal;

public class HandChangeViewRefresh extends Command{

	public function HandChangeViewRefresh() {
		super();
	}

	override public function execute():void {
		ModelBase.radioSilence = true;

		if(model.hand)
			onHandOn();
		else
			onHandOff();

		new RefreshTrees().execute();
	}

	private function onHandOn():void {
		initializeHandPositions();
	}

	private function onHandOff():void {

	}

	// задать начальное положение всем нодам, у которых его нет (на основании текущего)
	private function initializeHandPositions():void{
		// если все ноды еще не имеют hand-позиции, определить на основе текущей. Иначе нодам, не имеющим позиции,
		// надо будет рассчитать её на основе hand-позиций других нод

		var p:Person
		var n:Node;
		var n2:Node;
		var hasNodeWithHandPos:Boolean = false;
		var allPersons:Array = model.trees.iteratorForAllPersons();
		var pos:Point;

		for each(p in allPersons){
			if(p.node.handCoords){
				hasNodeWithHandPos = true;
				break;
			}
		}

		var checkIntersection:Array = [];// массив нод, которые могут пересекаться друг с другим или другими нодами. Двигать можно только их (вверх-вниз)
		var nonIntersectedNodes:Array = [];

		if(hasNodeWithHandPos){
			for each(var g:GenNode in model.generations.iterateAllGenNodes){
				n = g.node;
				if(!n.handCoords){
					if(g.join.from){
						Logic.calculateRelativePosition(g.join, true);// рассчет handX
						n.handY = n.level;// может быть пересечение
						checkIntersection.push(n);
					}else{
						// стартовая нода дерева
						n.handX = n.x;
						n.handY = n.level;
						nonIntersectedNodes.push(n);
					}
					model.handLog.add(n);
				}else
					nonIntersectedNodes.push(n);
			}
		}else{
			for each(p in allPersons){
				n = p.node;
				n.handX = n.x;
				n.handY = n.level;
				model.handLog.add(n);
			}
		}

		for each(n in checkIntersection){
			var startX:int = n.handX;
			var i:int = 0;
			var intersection:Boolean = true;
			while(intersection){
				intersection = false;
				n.handX = startX + 2 * Math.ceil(i / 2) * (i % 2 == 0 ? -1 : 1);
				i++;
				for each(n2 in nonIntersectedNodes)
					if(n.person.tree == n2.person.tree)
						if(n2.handY == n.handY && Math.abs(n2.handX - n.handX) < 2){// полное пересечение, либо расстояние между нодами по x меньше 2
							intersection = true;
							break;
						}
			}
			nonIntersectedNodes.push(n);
		}
	}
}
}
