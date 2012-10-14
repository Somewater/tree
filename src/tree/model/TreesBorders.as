package tree.model {

	/**
	 * Параметры, по которым ноды могу выкидываться из построения
	 */
	public class TreesBorders {
		public var maxNodesQuantity:int = 500;
		public var maxGenerationsDepth:int = 10;
		public var maxDepth:int = 10;

		public function TreesBorders(flashVars:Object) {
			if(int(flashVars['maxNodesQuantity']) > 0)
				maxNodesQuantity = int(flashVars['maxNodesQuantity']);

			if(int(flashVars['maxGenerationsDepth']) > 0)
				maxGenerationsDepth = int(flashVars['maxGenerationsDepth']);

			if(int(flashVars['maxDepth']) > 0)
				maxDepth = int(flashVars['maxDepth']);
		}
	}
}
