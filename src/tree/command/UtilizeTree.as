package tree.command {
	import tree.Tree;

	/**
	 * Очищает модель и вью, переводит флешку в первоначальное состояние, готовное к загрузке нового дерева
	 */
	public class UtilizeTree extends Command{
		public function UtilizeTree() {
		}

		override public function execute():void {
			model.hand = false;
			model.handLog.clear();
			Tree.instance.utilize();
			model.utilize();
		}
	}
}
