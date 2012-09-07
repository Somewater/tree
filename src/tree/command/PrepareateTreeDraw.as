package tree.command {

	/**
	 * Подготовиться к изменению дерева (добавлению или удалению нод)
	 */
	public class PrepareateTreeDraw extends Command{
		public function PrepareateTreeDraw() {
		}

		override public function execute():void {
			const maxTimeForAll:Number = model.treeViewConstructed ? 5 : 10;
			const maxTimeForOne:Number = 1;
			var number:int = Math.max(1,model.joinsForDraw.length + model.joinsForRemove.length);
			model.animationTime = Math.min(maxTimeForOne, maxTimeForAll / number);
		}
	}
}
