package tree.command {
	import tree.Tree;
	import tree.common.Bus;
	import tree.common.Config;
	import tree.model.Model;
	import tree.signal.RequestSignal;

	public class Actor {
		public var bus:Bus;

		public var model:Model;

		private var detained:Boolean = false;

		public function Actor() {
			var t:Tree = Tree.instance;
			this.bus = Config.inject(Bus);
			this.model = Config.inject(Model);
		}

		public function detain():void {
			if (Tree.instance.detainedCommands.indexOf(this) == -1)
				Tree.instance.detainedCommands.push(this);
			detained = true;
		}

		public function release():void {
			var i:int = Tree.instance.detainedCommands.indexOf(this);
			if (i != -1)
				Tree.instance.detainedCommands.splice(i, 1);
			detained = false;
		}

		protected function call(request:RequestSignal):void {
			bus.dispatch(RequestSignal.SIGNAL, request);
		}
	}
}
