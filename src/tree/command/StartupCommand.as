package tree.command {
	import tree.signal.RequestSignal;

	public class StartupCommand extends Command{
		public function StartupCommand() {
		}

		override public function execute():void {

			bus.loaderProgress.dispatch(0);

			// начать загрузку дерева, в соответствии с flashVars
			call(new RequestSignal(RequestSignal.USER_TREE));
		}
	}
}
