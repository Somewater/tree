package tree.command {
	public class TraceNodesOutput extends Command{
		public function TraceNodesOutput() {
		}

		override public function execute():void {
			debugTrace('Начинаем строить дерево...');

		}
	}
}
