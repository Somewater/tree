package tree.command {
	import tree.signal.RequestSignal;

	/**
	 * Загружает дерево другого человека
	 */
	public class ReloadTree extends Command{

		private var uid:int
		private var filter:int;

		public function ReloadTree(uid:int, filter:int = -1) {
			this.uid = uid;
			this.filter = filter;
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
