package tree.model {
import tree.model.SpatialMatrix;

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

		public function deleteTree(tree:TreeModel):void{
			var hashForRemove:Array = [];
			var hash:String
			for(hash in matrixByLevelAndTree){
				if(parseInt(hash.split(":")[1]) == tree.number)
					hashForRemove.push(hash);
			}

			for each(hash in hashForRemove){
				var sm:SpatialMatrix = matrixByLevelAndTree[hash];
				sm.clear();
				delete matrixByLevelAndTree[hash];
			}
		}
	}
}
