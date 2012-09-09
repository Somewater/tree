package tree.command {
	import tree.signal.RequestSignal;

	/**
	 * Загружает дерево другого человека
	 */
	public class ReloadTree extends Command{

		private var uid:int

		public function ReloadTree(uid:int) {
			this.uid = uid;
		}

		override public function execute():void {
			new UtilizeTree().execute();

			// начать загрузку дерева, в соответствии с flashVars
			var request:RequestSignal = new RequestSignal(RequestSignal.USER_TREE);
			request.uid = uid;
			call(request);
		}
	}
}
