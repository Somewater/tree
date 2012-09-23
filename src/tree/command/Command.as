package tree.command {
	import tree.common.Config;
	import tree.view.Window;
	import tree.view.window.MessageWindow;

	public class Command extends Actor {

		/**
		 * Имя нотифая, вызвавшего команду
		 */
		public var signalName:String;


		public function Command() {
			super();
		}

		public function execute():void
		{
		}

		protected function message(text:String):void{
			new MessageWindow(text).open();
		}

	}
}
