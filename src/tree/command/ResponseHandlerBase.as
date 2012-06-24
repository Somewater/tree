package tree.command {
	import tree.signal.ResponseSignal;

	public class ResponseHandlerBase extends Command{

		public var response:ResponseSignal;

		public function ResponseHandlerBase() {
		}
	}
}
