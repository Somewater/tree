package tree.model.base {
	import flash.geom.Point;

	import tree.model.base.IModel;

	/**
	 * Хранение и расчет инстансов типа IModel в двумерной системе координат
	 */
	public class SpatialMatrixBase {

		public static const OFFSET:int = 16;

		protected var spatial:Array = [];

		public function SpatialMatrixBase() {
		}

		protected function get(x:int, y:int):IModel {
			return spatial[x + (y << OFFSET)];
		}

		protected function set(data:IModel, x:int, y:int):void {
			if(data)
				spatial[x + (y << OFFSET)] = data;
			else
				delete(x + (y << OFFSET));
		}

		protected function has(x:int, y:int):Boolean {
			return spatial[x + (y << OFFSET)] != null;
		}
	}
}
