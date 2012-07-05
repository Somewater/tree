package tree.model {
	import tree.model.base.*;
	import flash.geom.Point;

	import tree.model.GenNode;

	public class SpatialMatrix extends SpatialMatrixBase{

		protected var tmpPoint:Point = new Point();

		public function SpatialMatrix() {
		}

		public function add(genNode:GenNode):Point {
			var x:int = genNode.node.x;
			var y:int = genNode.node.generation;
			var g:GenNode;

			if(genNode.node.uid == 13) {
				trace('ok')
			}

			const ORIG_VECT:int = -1;
			var startX:int = x;
			var vector:int = ORIG_VECT;
			var searchVector:int;// если предполагается искать свободное место только в одну сторону
			if(genNode.join.type.superType == JoinType.SUPER_TYPE_BRO
					|| genNode.join.type.superType == JoinType.SUPER_TYPE_PARENT
					|| genNode.join.type.superType == JoinType.SUPER_TYPE_EX_MARRY)
				searchVector = genNode.join.from.male ? -1 : 1;
			var delta:int = 0;
			var important:Boolean = genNode.join.type.superType == JoinType.SUPER_TYPE_MARRY;
			var cmp:int;

			while(important || (g = get(x, y) as GenNode)) {
				if(important || (cmp = compare(genNode, g)) > 0) {
					// определить вектор - с какой стороны пытаться распологать
					if(genNode.join.type.superType == JoinType.SUPER_TYPE_BRO)
						vector = genNode.join.from.male ? -1 : 1;// если bro, то слева от брата или справа от сестры (чтобы не мешать супругу)
					else
						vector = genNode.vector || 1;

					// убрать других и самому занять место
					var i:int = 1;
					var g2:GenNode;
					while(g){
						var nx:int = x + i * vector;
						g2 = get(nx, y) as GenNode;
						g.node.x = nx;
						g.node.firePositionChange();
						set(g,  nx, y)
						g = g2;
						i++;
					}
					break;
				} else {

					// todo: если это супруг, то сдвинуть всех.
					// todo: Если это потомство и не найдено место среди его братьев-сестер, то сдвинуть всех

					// заняться поиском места правее или левее
					vector = searchVector ? searchVector : -vector;
					if(searchVector || vector != ORIG_VECT)
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
	}
}
