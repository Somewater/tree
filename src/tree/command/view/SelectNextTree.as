package tree.command.view {
	import tree.command.Command;
	import tree.model.TreeModel;
	import tree.signal.ModelSignal;
	import tree.signal.ViewSignal;

	/**
	 * Выбрать следующее неотрисованное дерево для отрисовки
	 */
	public class SelectNextTree extends Command{
		public function SelectNextTree() {
		}

		override public function execute():void {
			var tree:TreeModel;
			for each(var _t:TreeModel in model.trees.iterator)
				if(!_t.visible){
					tree = _t;
					break;
				}

			if(tree){
				bus.dispatch(ModelSignal.TREE_NEED_CONSTRUCT, tree)
			}else{
				bus.dispatch(ViewSignal.ALL_TREES_COMPLETED)
			}
		}
	}
}
