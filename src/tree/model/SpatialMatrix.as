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

			const ORIG_VECT:int = -1;
			var startX:int = x;
			var vector:int = ORIG_VECT;
			var delta:int = 0;
			while(g = get(x, y) as GenNode) {
				var cmp:int = compare(genNode, g);
				if(cmp > 0) {
					// убрать других и самому занять место
					var i:int = 1;
					var g2:GenNode;
					while(g){
						var nx:int = x + i * vector;
						g2 = get(nx, y) as GenNode;
						set(g,  nx, y)
						g = g2;
						i++;
					}
					break;
				} else {
					// заняться поиском места правее или левее
					vector = -vector;
					if(vector != ORIG_VECT)
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
