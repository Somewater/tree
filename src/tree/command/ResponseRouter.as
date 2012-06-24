package tree.command {
	import tree.signal.RequestSignal;
	import tree.signal.ResponseSignal;

	public class ResponseRouter extends Command{

		private var response:ResponseSignal;

		public function ResponseRouter(response:ResponseSignal) {
			this.response = response;
		}

		override public function execute():void {
			var cmd:ResponseHandlerBase;

			switch(response.type)
			{
				case RequestSignal.USER_TREE:
					cmd = new ConstructTreeModel();
					cmd.response = response;
					cmd.execute();
					break;

				default:
					throw new Error('Unhandled response type \'' + response.type + '\'');
					break;
			}
		}
	}
}
