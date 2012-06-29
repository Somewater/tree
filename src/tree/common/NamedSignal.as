package tree.common {
	import org.osflash.signals.ISignal;
	import org.osflash.signals.PrioritySignal;

	internal class NamedSignal extends PrioritySignal implements INamedSignal
	{
		private var name:String;
		private var bus:ISignal;

		private var namedSignalListenersByName:Array;

		public function NamedSignal(bus:ISignal, name:String)
		{
			this.name = name;
			this.bus = bus;
			namedSignalListenersByName = [];
			super(String);
			addWithPriority(processNamedSignals, int.MAX_VALUE - 2);
		}

		private function processNamedSignals(signalName:String, ...data):void {
			var listeners:Array = namedSignalListenersByName[signalName];
			if(listeners)
				for each(var f:Function in listeners.slice())
					f.apply(null, data);
		}

		public function addNamed(name:String, listener:Function):void
		{
			var listeners:Array = namedSignalListenersByName[name];
			if(listeners == null)
				namedSignalListenersByName[name] = listeners = [];
			if(listeners.indexOf(listener) == -1)
				listeners.push(listener);
		}

		public function removeNamed(name:String, listener:Function):void
		{
			var listeners:Array = namedSignalListenersByName[name];
			if(listeners)
				listeners.splice(listeners.indexOf(listener), 1);
		}
	}
}
