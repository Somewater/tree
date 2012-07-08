package tree.view.canvas {
	import com.gskinner.motion.GTween;
	import com.gskinner.motion.GTweener;

	import flash.display.Sprite;
	import flash.events.Event;

	/**
	 * Умеет анимированно строить ломаную линию
	 */
	public class LineBase extends Sprite{

		private var _progress:Number = -1;

		public function LineBase() {

		}

		public function get progress():Number {
			return _progress;
		}

		public function set progress(value:Number):void {
			if(value != _progress) {
				_progress = value;
				draw();
			}
		}

		public function hide():void {
			GTweener.to(this, 0.2, {"alpha": 0});
		}

		/**
		 * Проявить и обновить состояние до корректного
		 *
		 * assets.HartLineIcon
		 */
		public function show():void {
			GTweener.to(this, 0.2, {"alpha": 1});
			_progress = 1;
			draw();
		}

		public function play(fromStart:Boolean = true):void {
			var from:Number = fromStart ? 0 : 1;
			var to:Number = fromStart ? 1 : 0;

			this.progress = from;
			GTweener.to(this, 0.3, {"progress": to}, {onComplete: dispatchOnComplete})
		}

		private function dispatchOnComplete(g:GTween):void {
			dispatchEvent(new Event(Event.COMPLETE))
		}

		public function draw():void {

		}
	}
}
