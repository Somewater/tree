package tree.model {
	import tree.model.base.*;
	import flash.geom.Point;

	import tree.model.GenNode;

	public class SpatialMatrix extends SpatialMatrixBase{

		public function SpatialMatrix() {
		}

		public function add(genNode:GenNode):Point {
			var x:Number = genNode.node.x;
			var y:Number = genNode.node.generation;
			var g:GenNode;

			const ORIG_VECT:int = -1;
			var startX:int = x;
			var vector:int = ORIG_VECT;
			var importantVector:int;// если предполагается искать свободное место только в одну сторону
			if(genNode.join.type.superType == JoinType.SUPER_TYPE_BRO
					|| genNode.join.type.superType == JoinType.SUPER_TYPE_PARENT
					|| genNode.join.type.superType == JoinType.SUPER_TYPE_EX_MARRY)
				importantVector = genNode.join.from.male ? -1 : 1;
			var delta:int = 0;
			var important:Boolean = false;
			var cmp:int;
			var joinSuperType:String = genNode.join.type.superType;
			var broCounter:int;
			var moverGenNodes:Array = [];

			while(important || (g = get(x, y) as GenNode)) {
				if(important || (cmp = compare(genNode, g)) > 0) {
					// определить вектор - с какой стороны пытаться распологать
					if(importantVector)
						vector = importantVector;
					else if(genNode.join.type.superType == JoinType.SUPER_TYPE_BRO)
						vector = genNode.join.from.male ? -1 : 1;// если bro, то слева от брата или справа от сестры (чтобы не мешать супругу)
					else
						vector = genNode.vector || 1;

					// убрать других и самому занять место
					if(!shift(moverGenNodes, genNode, x, y, vector))
						if(!shift(moverGenNodes, genNode, x, y, -vector))
							shift(moverGenNodes, genNode, x, y, vector, true);
							//throw new Error('Cant insert ' + genNode.node + ' in double directions');

					break;
				} else {

					// определяем случаи, когда надо форсированно сдвинуть многих
					if(joinSuperType == JoinType.SUPER_TYPE_MARRY){
						// если это супруг, то сдвинуть всех.
						important = true;
						if(x == 0 && y == 0)// если желает залезть прямо на zero
							x = genNode.node.person.marry.node.x;
						importantVector = checkNullNode(x, y, vector) ? -vector : vector;
						continue;
					}else if(joinSuperType == JoinType.SUPER_TYPE_BRO){
						if(g.node.person.bros.indexOf(genNode.node.person) == -1)
							broCounter++;
						if(broCounter > 1){// с обоих сторон "небратья", надо двигать всех
							important = true;
							importantVector = vector;
							continue;
						}
					}

					// заняться поиском места правее или левее
					vector = importantVector ? importantVector : -vector;
					if(importantVector || vector != ORIG_VECT)
						delta++;
					x = startX + delta * vector;
				}
			}

			for each(g in moverGenNodes)
			{
				g.node.firePositionChange();
				error('refresh node: ' + g.node);
			}

			set(genNode, x, y)
			tmpPoint.x = x;
			tmpPoint.y = y;
			return tmpPoint;
		}

		public function remove(g:GenNode):Point {

			if(get(g.node.x,  g.node.y) == g) {
				set(null, g.node.x, g.node.y);
				return shiftUnderPoint(g.node.x, g.node.y);
			}

			for(var key:* in spatial)
				if(spatial[key] == g)
				{
					delete(spatial[key]);
					var x:int = int(key) & 0xFFFF;
					var y:int = int(key) >>> SpatialMatrixBase.OFFSET;
					return shiftUnderPoint(x, y);
				}

			throw new Error('Can`t find this model ' + g);
		}
	}
}
