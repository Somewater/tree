package tree.model.lines {
	import tree.model.*;
	import flash.geom.Point;

	import tree.model.lines.LineMatrix;

	public class LineMatrixCollection{

		private var MAX_SHIFT:int = 5;


		private var utilizedLines:Array = [];

		private var tmpPoint:Point = new Point();

		private var horizontalMatrixesByMask:Array = [];
		private var verticalMatrixesByMask:Array = [];

		public function LineMatrixCollection() {
		}

		public function align(lines:Array, data:Join, mask:int = 0):Point {
			tmpPoint.x = 0;
			tmpPoint.y = 0;
			var i:int;
			var len:int = lines.length - 2;
			var x1:int;
			var x2:int;
			var y1:int;
			var y2:int;
			var l:Line;

			var hlines:Array = [];
			var vlines:Array = [];

			for(i = 0; i < len; i += 2){
				x1 = lines[i];
				y1 = lines[i + 1];
				x2 = lines[i + 2];
				y2 = lines[i + 3];
				if(x1 != x2){
					l = createLine();
					l.join = data;
					l.horizontal = true;
					l.constant = y1;
					if(x1 < x2){
						l.start = x1; l.end = x2;
					}else{
						l.start = x2; l.end = x1;
					}
					hlines.push(l);
				}else if(y1 != y2){
					l = createLine();
					l.join = data;
					l.horizontal = false;
					l.constant = x1;
					if(y1 < y2){
						l.start = y1;
						l.end = y2;
					}else{
						l.start = y2;
						l.end = y1;
					}
					vlines.push(l);
				}
			}

			var matrixesByMask:Array;
			var m:LineMatrix;
			var dirLines:Array;
			var shift:int = 0;
			var vector:int = 0;
			var horizontal:Boolean = true;
			var intersection:Boolean;
			var step:int;

			for(i = 0; i<2; i++, horizontal = false){
			    dirLines = i == 0 ? hlines : vlines;
				step = 0;
				intersection = true;

				while(intersection){
					intersection = false;

					for each(l in dirLines){
						matrixesByMask = l.horizontal ? this.horizontalMatrixesByMask : this.verticalMatrixesByMask;
						m = matrixesByMask[mask];
						if(!m)
							matrixesByMask[mask] = m = new LineMatrix(l.horizontal, mask);
						if(!m.empty(l.start, l.end, l.constant + shift, l.join)){
							intersection = true;
							break;
						}
					}

					if(intersection){
						step++
						if(step * 0.5 > MAX_SHIFT)
							shift = Math.random() * (MAX_SHIFT * 2 + 1) - MAX_SHIFT;
						else
							shift = Math.ceil(step / 2) * (step % 2 == 0 ? 1 : -1);
					}else{
						if(horizontal) tmpPoint.y = shift; else tmpPoint.x = shift;
					}
				}
			}

			if(hlines.length)
				LineMatrix(horizontalMatrixesByMask[mask]).addFor(data, hlines);

			if(vlines.length)
				LineMatrix(verticalMatrixesByMask[mask]).addFor(data, vlines);


			return tmpPoint;
		}

		private function createLine():Line{
			if(utilizedLines.length)
				utilizedLines.pop();
			return new Line();
		}

		public function utilize(lines:Array, data:Join, mask:int = 0):void {
			var len:int = lines.length - 2;
			var x1:int, x2:int,  y1:int,  y2:int;
			var m:LineMatrix;
			var utilization:Array = [];
			for(var i:int = 0; i < len; i += 2){
				x1 = lines[i];
				y1 = lines[i + 1];
				x2 = lines[i + 2];
				y2 = lines[i + 3];

				if(x1 != x2)
					m = horizontalMatrixesByMask[mask];
				else if(y1 != y2)
					m = verticalMatrixesByMask[mask];
				else
					continue;

				utilization = utilization.concat(m.clearBy(data));
			}

			for each(var l:Line in utilization)
				utilizedLines.push(l);
		}
	}
}
