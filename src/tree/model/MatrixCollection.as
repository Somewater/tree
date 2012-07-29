package tree.model {
	public class MatrixCollection {

		protected var matrixByLevelAndTree:Array = [];

		public function MatrixCollection() {
		}

		public function byLevelAndTree(level:int, tree:TreeModel):SpatialMatrix {
			var hash:String = level + ":" + tree.number;
			var m:SpatialMatrix = matrixByLevelAndTree[hash];
			if(!m)
				matrixByLevelAndTree[hash] = m = new SpatialMatrix();
			return m;
		}

		public function clear():void{
			matrixByLevelAndTree = [];
		}
	}
}
