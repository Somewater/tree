package tree.model.base {
	import flash.geom.Point;

	import tree.model.GenNode;

	public class SpatialMatrix extends SpatialMatrixBase{

		protected var tmpPoint:Point = new Point();

		public function SpatialMatrix() {
		}

		public function add(g:GenNode):Point {
			var x:int = g.node.x;
			var y:int = g.node.y;
			// todo: проверить и найти ближайшую незанятую позицию
			set(g, x, y)
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
	}
}
