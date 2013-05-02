package tree.model.base {
	import flash.geom.Point;

	import tree.model.GenNode;
	import tree.model.Person;

	import tree.model.base.IModel;

	/**
	 * Хранение и расчет инстансов типа IModel в двумерной системе координат
	 */
	public class SpatialMatrixBase {

		public static const OFFSET:int = 16;

		protected var spatial:Array = [];
		protected var tmpPoint:Point = new Point();

		public function SpatialMatrixBase() {
		}

		public function get(x:Number, y:Number):GenNode {
			CONFIG::debug{
				return spatial[x + ',' + y];
			}
			return spatial[x + (y << OFFSET)];
		}

		public function getInArea(x:Number, y:Number):GenNode {
			var g:GenNode = get(x, y);
			if(g) return g;
			g = get(x + 1, y);
			if(g) return g;
			g = get(x - 1, y);
			return g;
		}

		public function set(data:GenNode, x:Number, y:Number):void {
			CONFIG::debug{
				if(data){
					spatial[x + ',' + y] = data;
					// проверка, что поблизости нет ссылок на ту же ноду
					//if(get(x + 1, y) == data)
					//	set(null, x + 1, y);
					//else if(get(x - 1, y) == data)
					//	set(null, x - 1, y);
				}else
					delete(spatial[x + ',' + y]);
				return;
			}
			if(data){
				spatial[x + (y << OFFSET)] = data;
				// проверка, что поблизости нет ссылок на ту же ноду
				//if(get(x + 1, y) == data)
				//	set(null, x + 1, y);
				//else if(get(x - 1, y) == data)
				//	set(null, x - 1, y);
			}else
				delete(spatial[x + (y << OFFSET)]);
		}

		public function check():void{
			CONFIG::debug{
				var all:Array = [];
				var data:GenNode;
				for each(data in spatial)
					all.push(data);
				for each(data in all.slice()){
					var counter:int = 0;
					for each(var g:GenNode in all)
						if(g == data){
							counter++;
							if(counter > 1)
								throw new Error('Doublicated spatial entries');
						}
				}
			}
		}

		//////////////////////////////////////////////
		//                                          //
		//  			H E L P E R S				//
		//                                          //
		//////////////////////////////////////////////

		protected function shiftUnderPoint(x:int, y:int):Point {
			tmpPoint.x = x;
			tmpPoint.y = y;
			return tmpPoint;
		}

		/**
		 * @return положительное число, если g1 имеет больший приоритет занимать место в матрице, чем g2
		 */
		protected function compare(g1:GenNode, g2:GenNode):int {
			return g1.priority - g2.priority;
		}

		/**
		 * Переместить node влево или вправо (соответственно, сдвинуть следующие ноды, если появится необходимость)
		 * Если какой-либо вызов возвращает false, перемещение откатывается
		 * @return перемещение произведено успешно
		 */
		protected function shift(shifted:Array, substitute:GenNode, x:Number, y:Number, vector:int, important:Boolean = false):Boolean {
			var g:GenNode = getInArea(x, y);
			if(g){
				if(!important && compare(g,  substitute) > 0)
					return false;// смещение противоречит правилам

				var m:Person;
				if(!important && (m = g.node.marry) && m.visible && Math.abs(m.node.x - x - vector * 2) > 1)
					return false;// проверка, что смещение разделяет супругов

				if(!shift(shifted, g, x + vector * 2, y,  vector, important))
					return false;// в цепи выполнения сдвигов произошло противоречие

				g.node.x = x + vector * 2;
				g.node.y = y;
				shifted.push(g);
			}

			set(substitute, x, y);
			return true;
		}

		/**
		 * Проверка, что если двигаться в заданном векторе от указанной точки, то можно дойти до родоначлаьника дерева
		 */
		protected function checkNullNode(x:int, y:int, vector:int):Boolean {
			var g:GenNode
			while(g = getInArea(x, y)) {
				if(g.node.dist == 0)
					return true;
				x += vector * 2;
			}
			return false;
		}
	}
}
