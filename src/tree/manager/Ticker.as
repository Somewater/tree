package tree.manager {
	import flash.display.Stage;
	import flash.events.Event;
	import flash.utils.getTimer;

	public class Ticker implements ITicker{

		protected var lastTickTIme:uint = 0;

		protected var deferredCallbacksByFrames:Vector.<DC>;
		protected var deferredCallbacksByMS:Vector.<DC>;
		protected var tickers:Vector.<ITick>;

		public function Ticker(stage:Stage) {
			deferredCallbacksByFrames = new Vector.<DC>();
			deferredCallbacksByMS = new Vector.<DC>();
			tickers = new Vector.<ITick>();
			stage.addEventListener(Event.ENTER_FRAME, onTick);
		}

		private function onTick(event:Event):void {
			var getTimer:int = flash.utils.getTimer();
			var delta:int = getTimer - lastTickTIme;
			lastTickTIme = getTimer;

			var i:int = 0;
			var dc:DC;
			while(i < deferredCallbacksByFrames.length) {
				dc = deferredCallbacksByFrames[i];
				dc.frames--;
				if(dc.frames <= 0)
				{
					if(!dc.args)
						dc.callback();
					else
						dc.callback.apply(null, dc.args);
					deferredCallbacksByFrames.splice(i, 1);
				}
				else
					i++;
			}

			while(i < deferredCallbacksByMS.length) {
				dc = deferredCallbacksByMS[i];
				dc.ms -= delta;
				if(dc.ms <= 0)
				{
					if(!dc.args)
						dc.callback();
					else
						dc.callback.apply(null, dc.args);
					deferredCallbacksByMS.splice(i, 1);
				}
				else
					i++;
			}

			for each(var tick:ITick in tickers)
				tick.tick(delta);
		}

		public function callLater(callback:Function, frames:int = 1, args:Array = null):void {
			var dc:DC = new DC();
			dc.callback = callback;
			dc.frames = frames;
			dc.args = args;
			deferredCallbacksByFrames.push(dc);
		}

		public function defer(callback:Function, ms:int, args:Array = null):void {
			var dc:DC = new DC();
			dc.callback = callback;
			dc.ms = ms;
			dc.args = args;
			deferredCallbacksByMS.push(dc);
		}

		public function add(tick:ITick):void {
			if(tickers.indexOf(tick) == -1)
				tickers.push(tick);
		}

		public function remove(tick:ITick):void {
			var idx:int = tickers.indexOf(tick);
			if(idx != -1)
				tickers.splice(idx, 1);
		}

		public function get getTimer():uint {
			return lastTickTIme;
		}
	}
}
class DC {
	public var callback:Function;
	public var args:Array;
	public var frames:int;
	public var ms:int;
}
