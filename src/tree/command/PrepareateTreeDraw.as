package tree.command {

	/**
	 * Подготовиться к изменению дерева (добавлению или удалению нод)
	 */
	public class PrepareateTreeDraw extends Command{
		public function PrepareateTreeDraw() {
		}

		override public function execute():void {
			const maxTimeForAll:Number = model.treeViewConstructed ? model.options.maxTreeConstructTime : model.options.maxTreeConstructTimeTreeUncompl;
			const maxTimeForOne:Number = model.options.minNodeConstructTime;
			var number:int = Math.max(1,model.joinsForDraw.length + model.joinsForRemove.length);
			if(model.options.animation)
				model.animationTime = Math.min(maxTimeForOne, maxTimeForAll / number);
			else
				model.animationTime = 0;
			if(!model.owner.editable || !model.options.handPermitted)
				model.hand = false;
			model.handLog.clear();
		}
	}
}
