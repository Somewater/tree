package tree.command {

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

	}
}
