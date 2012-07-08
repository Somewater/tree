package tree.view.canvas {
	import com.gskinner.motion.GTween;
	import com.gskinner.motion.GTweener;

	import flash.display.Sprite;
	import flash.events.Event;

	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;

	import tree.common.IClear;

	/**
	 * Умеет анимированно строить ломаную линию
	 */
	public class LineBase extends Sprite implements IClear{

		protected var _progress:Number = -1;
		protected var fromStart:Boolean = true;
		public var complete:ISignal;



		public function LineBase() {
			complete = new Signal(LineBase);
		}

		public function clear():void {

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

		public function hide(animated:Boolean = true):void {
			if(animated){
				GTweener.to(this, 0.5, {"alpha": 0});
			}else{
				alpha = 0;
			}
		}

		/**
		 * Проявить и обновить состояние до корректного
		 *
		 * assets.HartLineIcon
		 */
		public function show(animated:Boolean = true):void {
			if(animated){
				GTweener.to(this, 0.2, {"alpha": 1});
			}else{
				alpha = 1;
			}
			_progress = 1;
			draw();
		}

		public function play(fromStart:Boolean = true):void {
			var from:Number = fromStart ? 0 : 1;
			var to:Number = fromStart ? 1 : 0;

			this.fromStart = fromStart;
			this.progress = from;
			GTweener.to(this, 0.3, {"progress": to}, {onComplete: dispatchOnComplete})
		}

		private function dispatchOnComplete(g:GTween):void {
			complete.dispatch(this);
		}

		public function draw():void {
			throw new Error('Override me');
		}

		/**
		 *
		 * @param line массив координат [x0, y0, x1, y1 ...]
		 */
		protected function drawLine(line:Array, length:int):void{
			var l:int = 0;
			var lastX:int;
			var lastY:int;
			var x:int;
			var y:int;
			var i:int;
			while(i < line.length && l < length) {
				x = line[i];
				y = line[i + 1];
				var dist:int = 0;
				if(i == 0){
					graphics.clear();
					configurateLine();
					graphics.moveTo(x, y);
				}else{
					var dx:int = x - lastX;
					var dy:int = y - lastY;
					dist = dx * dx + dy * dy;
					if(l + dist > length){
						var r:Number = (length - l) / dist;
						x = lastX + dx * r;
						y = lastY + dy * r;
					}
					graphics.lineTo(x, y);
				}
				lastX = x;
				lastY = y;
				i += 2;
				l += dist;
			}
		}

		protected function configurateLine():void {
			throw new Error('Override me');
		}
	}
}
