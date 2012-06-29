package tree.common {
	import flash.display.Stage;
	import flash.events.Event;
	import flash.geom.Point;

	import org.osflash.signals.IPrioritySignal;

	import org.osflash.signals.ISignal;
	import org.osflash.signals.PrioritySignal;
	import org.osflash.signals.Signal;

	public class Bus extends NamedSignal{

		public var sceneResize:IPrioritySignal;// callback(point:Point)
		private var resizePoint:Point;


		/**
		 * Надо показать или скрыть лоадер. Передаются проценты загрузки  0..1,
		 * <нет аргумента>    - если надо скрыть
		 * <= 0 - если не надо показывать прогресс
		 */
		public var loaderProgress:IPrioritySignal;// callback(progress:Number)


		/**
		 * Сигналы от view Canvas
		 */
		public var canvas:INamedSignal;

		public function Bus(stage:Stage) {
			super(null, '');

			sceneResize = new BusSignal(this, 'sceneResize', Point);
			resizePoint = new Point(stage.stageWidth, stage.stageHeight);
			stage.addEventListener(Event.RESIZE, onResize);

			loaderProgress = new BusSignal(this, 'loaderProgress');

			canvas = new NamedSignal(this, 'canvas');
		}

		private function onResize(event:Event):void {
			resizePoint.x = Config.WIDTH = (event.currentTarget as Stage).stageWidth;
			resizePoint.y = Config.HEIGHT = (event.currentTarget as Stage).stageHeight;
			sceneResize.dispatch(resizePoint);
		}
	}
}

import org.osflash.signals.ISignal;
import org.osflash.signals.PrioritySignal;


class BusSignal extends PrioritySignal
{
	private var name:String;
	private var bus:ISignal;

	public function BusSignal(bus:ISignal, name:String, ...classes)
	{
		this.name = name;
		this.bus = bus;
		super(classes);
	}
}