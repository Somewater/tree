package tree.model.lines {
	import tree.model.Join;

	public class LineMatrix{

		private var byJoin:Array = [];

		/**
		 * linesByConstant[<constant>] == array of lines
		 */
		private var linesByConstant:Array = [];

		private var horizontal:Boolean;
		private var mask:int;

		public function LineMatrix(horizontal:Boolean, mask:int) {
			this.horizontal = horizontal;
			this.mask = mask;
		}

		public function addFor(join:Join, array:Array, shiftValues:int, shiftConstant:int):void{
			CONFIG::debug{
				if(byJoin[join])
					throw new Error('Array lines by join already filled');
			}
			byJoin[join.uniqId] = array;
			var lines:Array;
			var i:int;
			var l:Line;
			var l2:Line;
			var inserted:Boolean;
			for each(l in array){
				l.start += shiftValues;
				l.end += shiftValues;
				l.constant += shiftConstant;
				lines = linesByConstant[l.constant];
				if(!lines)
					linesByConstant[l.constant] = lines = [];
				inserted = false;
				for(i = 0;i<lines.length;i++){
					l2 = lines[i];
					if(l2.start > l.end){
						lines.splice(i, 0, l);
						inserted = true;
						break;
					}
				}
				if(!inserted)
					lines.push(l);
			}
		}

		public function clearBy(join:Join):Array{
			var joinId:String = join.uniqId;
			var arr:Array = byJoin[joinId];
			delete(byJoin[joinId]);
			var lines:Array;
			var l:Line;
			var index:int;
			for each(l in arr) {
				lines = linesByConstant[l.constant];
				index = lines.indexOf(l);
				if(index != -1)
					lines.splice(index, 1);
			}
			return arr;
		}

		public function empty(start:int, end:int, constant:int, from:uint, to:uint):Boolean{
			var lines:Array = linesByConstant[constant];
			if(lines)
				for each(var l:Line in lines)
					if(!(l.from == from || l.to == to || l.from == to || l.to == from)
							&& !(l.start > end || l.end < start)) {
						//error("INTERSECTION: " + this + "\t" + start + ".." + end + " (" + constant + ")")
						return false;
					}
			return true;
		}

		public function toString():String{
			return '[' + (horizontal ? 'hor ' : 'ver ') + mask + ']';
		}
	}
}
