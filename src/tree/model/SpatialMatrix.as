package tree.model {
	import tree.model.base.*;
	import flash.geom.Point;

	import tree.model.GenNode;

	public class SpatialMatrix extends SpatialMatrixBase{

		protected var tmpPoint:Point = new Point();

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
					if(!shift(genNode, x, y, vector))
						if(!shift(genNode, x, y, -vector))
							shift(genNode, x, y, vector, true);
							//throw new Error('Cant insert ' + genNode.node + ' in double directions');

					break;
				} else {

					// определяем случаи, когда надо форсированно сдвинуть многих
					if(joinSuperType == JoinType.SUPER_TYPE_MARRY){// todo: если это супруг, то сдвинуть всех.
						important = true;
						if(x == 0 && y == 0)// если желает залезть прямо на zero
							x = genNode.node.person.marry.node.x;
						importantVector = checkNullNode(x, y, vector) ? -vector : vector;
						continue;
					}else if(joinSuperType == JoinType.SUPER_TYPE_BRO){// todo: Если это потомство и не найдено место среди его братьев-сестер, то сдвинуть всех
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

		private function shiftUnderPoint(x:int, y:int):Point {
			tmpPoint.x = x;
			tmpPoint.y = y;
			return tmpPoint;
		}

		/**
		 * @return положительное число, если g1 имеет больший приоритет занимать место в матрице, чем g2
		 */
		private function compare(g1:GenNode, g2:GenNode):int {
			return g1.priority - g2.priority;
		}

		/**
		 * Переместить node влево или вправо (соответственно, сдвинуть следующие ноды, если появится необходимость)
		 * Если какой-либо вызов возвращает false, перемещение откатывается
		 * @return перемещение произведено успешно
		 */
		private function shift(substitute:GenNode, x:Number, y:Number, vector:int, important:Boolean = false):Boolean {
			var g:GenNode = get(x, y);
			if(g){
				if(important || compare(g,  substitute) > 0)
					return false;// смещение противоречит правилам

				if(!shift(g, x + vector, y,  vector, important))
					return false;// в цепи выполнения сдвигов произошло противоречие

				g.node.x = x + vector;
				g.node.y = y;
				g.node.firePositionChange();
			}

			set(substitute, x, y);
			return true;
		}

		private function checkNullNode(x:int, y:int, vector:int):Boolean {
			var g:GenNode
			while(g = get(x, y)) {
				if(g.node.dist == 0)
					return true;
				x += vector;
			}
			return false;
		}
	}
}
