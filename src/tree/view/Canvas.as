package tree.view {
	import flash.display.Sprite;

	import org.osflash.signals.ISignal;

	import tree.common.Bus;

	import tree.common.Config;
	import tree.model.Model;
	import tree.model.NodesCollection;
	import tree.model.PersonsCollection;

	public class Canvas extends Sprite{

		private var bus:Bus;
		private var model:Model;

		public function Canvas(bus:Bus, model:Model) {
			this.bus = bus;
			this.model = model;
		}

		public function clear():void
		{

		}
	}
}
