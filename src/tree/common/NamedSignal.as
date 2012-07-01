package tree.common {
	import org.osflash.signals.ISignal;
	import org.osflash.signals.PrioritySignal;

	import tree.command.Command;

	internal class NamedSignal extends PrioritySignal implements INamedSignal
	{
		private var name:String;
		private var bus:ISignal;

		private var namedSignalListenersByName:Array;
		private var commandsByName:Array;

		public function NamedSignal(bus:ISignal, name:String)
		{
			this.name = name;
			this.bus = bus;
			namedSignalListenersByName = [];
			commandsByName = [];
			super(String);
			addWithPriority(processNamedSignals, int.MAX_VALUE - 2);
		}

		private function processNamedSignals(signalName:String, ...data):void {
			var listeners:Array = namedSignalListenersByName[signalName];
			if(listeners)
				for each(var f:Function in listeners.slice())
					f.apply(null, data);

			listeners = commandsByName[signalName];
			if(listeners) {
				for each(var commandCl:Class in listeners)
				{
					var command:Command;
					if(!data || data.length == 0)
						command = new commandCl();
					else if(data.length == 1)
						command = new commandCl(data[0]);
					else if(data.length == 2)
						command = new commandCl(data[0], data[1]);
					else if(data.length == 3)
						command = new commandCl(data[0], data[1], data[2]);
					else if(data.length == 4)
						command = new commandCl(data[0], data[1], data[2], data[3]);
					else if(data.length == 5)
						command = new commandCl(data[0], data[1], data[2], data[3], data[4]);

					command.execute();
				}
			}
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

		public function addCommand(name:String, command:Class):void {
			var listeners:Array = commandsByName[name];
			if(listeners == null)
				commandsByName[name] = listeners = [];
			if(listeners.indexOf(command) == -1)
				listeners.push(command);
		}
	}
}
