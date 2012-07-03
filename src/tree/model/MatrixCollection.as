package tree.model {
	public class MatrixCollection {

		protected var matrixByLevel:Array = [];

		public function MatrixCollection() {
		}

		public function byLevel(level:int):SpatialMatrix {
			var m:SpatialMatrix = matrixByLevel[level];
			if(!m)
				matrixByLevel[level] = m = new SpatialMatrix();
			return m;
		}
	}
}
