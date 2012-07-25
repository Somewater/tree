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
			var x1:int = lines[0];
			var y1:int = lines[1];
			var x2:int = lines[lines.length - 2];
			var y2:int = lines[lines.length - 1];
			var l:Line;

			var from:uint = (x1 + 0x7FFF) + (y1 + 0x7FFF) << 0x10;
			var to:uint = (x2 + 0x7FFF) + (y2 + 0x7FFF) << 0x10;

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

				l.from = from;
				l.to = to;
			}

			var matrixesByMask:Array;
			var m:LineMatrix;
			var dirLines:Array;
			var shift:int = 0;
			var horizontal:Boolean = true;
			var intersection:Boolean;
			var step:int;
			var otherShift:int = 0;

			for(i = 0; i<2; i++, horizontal = false){
			    dirLines = i == 0 ? hlines : vlines;
				step = 0;
				shift = 0;
				intersection = true;

				while(intersection){
					intersection = false;

					for each(l in dirLines){
						matrixesByMask = l.horizontal ? this.horizontalMatrixesByMask : this.verticalMatrixesByMask;
						m = matrixesByMask[mask];
						if(!m)
							matrixesByMask[mask] = m = new LineMatrix(l.horizontal, mask);
						if(!m.empty(l.start + otherShift, l.end + otherShift, l.constant + shift, from, to)){
							intersection = true;
							break;
						}
					}

					if(intersection){
						step++
						if(step * 0.5 > MAX_SHIFT)
							shift = Math.random() * (MAX_SHIFT * 2 + 1) - MAX_SHIFT;
						else
							shift = -(step > MAX_SHIFT ? MAX_SHIFT - step : step);//Math.ceil(step / 2) * (step % 2 == 0 ? 1 : -1);
					}else{
						if(horizontal) tmpPoint.y = shift; else tmpPoint.x = shift;
						otherShift = shift;
					}
				}
			}

			if(hlines.length)
				LineMatrix(horizontalMatrixesByMask[mask]).addFor(data, hlines, tmpPoint.x, tmpPoint.y);

			if(vlines.length)
				LineMatrix(verticalMatrixesByMask[mask]).addFor(data, vlines, tmpPoint.y, tmpPoint.x);


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
