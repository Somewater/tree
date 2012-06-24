package tree.common {
	import flash.display.Stage;
	import flash.events.Event;
	import flash.geom.Point;

	import org.osflash.signals.IPrioritySignal;

	import org.osflash.signals.ISignal;
	import org.osflash.signals.PrioritySignal;
	import org.osflash.signals.Signal;

	public class Bus extends PrioritySignal{

		public var sceneResize:IPrioritySignal;
		private var resizePoint:Point;

		/**
		 * Надо показать или скрыть лоадер. Передаются проценты загрузки  0..1,
		 * <нет аргумента>    - если надо скрыть
		 * <= 0 - если не надо показывать прогресс
		 */
		public var loaderProgress:IPrioritySignal;

		private var namedSignalListenersByName:Array = [];

		public function Bus(stage:Stage) {
			super(String);

			sceneResize = new BusSignal(this, 'sceneResize', Point);
			resizePoint = new Point(stage.stageWidth, stage.stageHeight);
			stage.addEventListener(Event.RESIZE, onResize);

			loaderProgress = new BusSignal(this, 'loaderProgress');

			addWithPriority(processNamedSignals, int.MAX_VALUE - 2);
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

		private function onResize(event:Event):void {
			resizePoint.x = Config.WIDTH = (event.currentTarget as Stage).stageWidth;
			resizePoint.y = Config.HEIGHT = (event.currentTarget as Stage).stageHeight;
			sceneResize.dispatch(resizePoint);
		}

		private function processNamedSignals(signalName:String, ...data):void {
			var listeners:Array = namedSignalListenersByName[signalName];
			if(listeners)
				for each(var f:Function in listeners.slice())
					f.apply(null, data);
		}
	}
}

import org.osflash.signals.PrioritySignal;
import org.osflash.signals.Signal;

import tree.common.Bus;

class BusSignal extends PrioritySignal
{
	public function BusSignal(bus:Bus, name:String, ...classes)
	{
		super(classes);
	}
}