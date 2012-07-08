package tree.model.base {
	import flash.geom.Point;

	import tree.model.GenNode;

	import tree.model.base.IModel;

	/**
	 * Хранение и расчет инстансов типа IModel в двумерной системе координат
	 */
	public class SpatialMatrixBase {

		public static const OFFSET:int = 16;

		protected var spatial:Array = [];

		public function SpatialMatrixBase() {
		}

		protected function get(x:Number, y:Number):GenNode {
			CONFIG::debug{
				return spatial[x + ',' + y];
			}
			return spatial[x + (y << OFFSET)];
		}

		protected function set(data:GenNode, x:Number, y:Number):void {
			CONFIG::debug{
				if(data)
					spatial[x + ',' + y] = data;
				else
					delete(spatial[x + ',' + y]);
				return;
			}
			if(data)
				spatial[x + (y << OFFSET)] = data;
			else
				delete(spatial[x + (y << OFFSET)]);
		}

		protected function has(x:Number, y:Number):Boolean {
			CONFIG::debug{
				return spatial[x + ',' + y] != null;
			}
			return spatial[x + (y << OFFSET)] != null;
		}
	}
}
