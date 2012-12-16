package tree.manager {
import tree.model.Join;
import tree.model.JoinType;
import tree.model.Node;
import tree.model.Person;

/**
 * Статические функции алгоритмов
 */
public class Logic {
	public function Logic() {
	}

	public static function calculateNode(node:Node, source:Node, flatten:Boolean, breed:Boolean):void{
		if(source) {
			// назначаем параметры, относительно owner
			node.dist = source.dist + 1;
			if(flatten) {
				node.vector = source.vector;
				node.generation = source.generation;
			} else {
				if(breed) {
					node.vector = -1;
					node.generation = source.generation + 1;
				} else {
					node.vector = 1;
					node.generation = source.generation - 1;
				}
			}

			if(source.vector != 0 && source.vector + node.vector == 0)
				node.vectCount = source.vectCount + 1;
			else
				node.vectCount = source.vectCount;
		} else {
			node.generation = 0;
			node.dist = 0;
			node.vector = 0;
			node.vectCount = 0;
		}
	}

	public static function calculateRelativePosition(join:Join, hand:Boolean = false):void {
		var source:Person = join.from;
		var sourceNode:Node;
		if(source)
			sourceNode = source.node;

		var node:Node = join.associate.node;
		var hasLegitimateBreed:Boolean;

		switch(join.type ? join.type.superType : null) {
			case JoinType.SUPER_TYPE_MARRY:
				if(hand){
					node.handX = sourceNode.handX + (join.type == Join.WIFE ? 2 : -2);
				}else{
					node.x = sourceNode.x + (join.type == Join.WIFE ? 2 : -2);
					node.oddX = sourceNode.oddX;
				}
				break;
			case JoinType.SUPER_TYPE_BREED:
				hasLegitimateBreed = sourceNode.person.hasLegitimateBreed()
				if(hand){
					node.handX = sourceNode.handX + (hasLegitimateBreed ? (sourceNode.person.male ? 1 : -1) : 0);
				}else{
					node.x = sourceNode.x + (hasLegitimateBreed ? (sourceNode.person.male ? 1 : -1) : 0);
					node.oddX = hasLegitimateBreed ? !sourceNode.oddX : sourceNode.oddX;
				}
				break;
			case JoinType.SUPER_TYPE_PARENT:
				hasLegitimateBreed = node.person.hasLegitimateBreed()
				if(hand){
					node.handX = sourceNode.handX + (hasLegitimateBreed ? (node.person.male ? -1 : 1) : 0);
				}else{
					node.x = sourceNode.x + (hasLegitimateBreed ? (node.person.male ? -1 : 1) : 0);
					node.oddX = hasLegitimateBreed ? !sourceNode.oddX : sourceNode.oddX;
				}
				break;
			case JoinType.SUPER_TYPE_BRO:
			case JoinType.SUPER_TYPE_EX_MARRY:
				if(hand){
					node.handX = sourceNode.handX + (source.male ? -2 : 2);
				}else{
					node.x = sourceNode.x + (source.male ? -2 : 2);
					node.oddX = sourceNode.oddX;
				}
				break;
			default:
				if(source || hand)
					throw new Error('Undefined join super type');

				// мы имеем перво с самой первой нодой дерева (относительно которой строится всё дерево)
				node.x = 0;
				node.oddX = true;
		}
	}
}
}
