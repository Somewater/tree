package tree.view.canvas {
	import com.gskinner.motion.GTween;
	import com.gskinner.motion.GTweener;

	import flash.display.Sprite;
	import flash.events.Event;

	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;

	import tree.common.IClear;
	import tree.model.Model;
	import tree.view.Tweener;

	/**
	 * Умеет анимированно строить ломаную линию
	 */
	public class LineBase extends Sprite implements IClear{

		protected var _progress:Number = -1;
		protected var fromStart:Boolean = true;
		protected var dashed:Boolean = false;
		public var complete:ISignal;
		public var hided:ISignal;

		protected var shiftX:int = 0;
		protected var shiftY:int = 0;



		public function LineBase() {
			complete = new Signal(LineBase);
			hided = new Signal(LineBase);
		}

		public function clear():void {
			GTweener.removeTweens(this);
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
				GTweener.removeTweens(this);
				Tweener.to(this, Model.instance.animationTime * 0.5, {"alpha": 0},{onComplete: dispatchHideComplete});
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
				GTweener.removeTweens(this);
				Tweener.to(this, Model.instance.animationTime * 0.3, {"alpha": 1});
			}else{
				alpha = 1;
			}
			_progress = 1;
			refreshLines();
			draw();
		}

		public function play(fromStart:Boolean = true):void {
			var from:Number = fromStart ? 0 : 1;
			var to:Number = fromStart ? 1 : 0;

			this.fromStart = fromStart;
			refreshLines();
			this.progress = from;
			this.alpha = 1;
			Tweener.to(this, Model.instance.animationTime * 0.4, {"progress": to}, {onComplete: dispatchPlayComplete})
		}

		protected function refreshLines():void {
			throw new Error('Override me');
		}

		private function dispatchPlayComplete(g:GTween = null):void {
			complete.dispatch(this);
		}

		private function dispatchHideComplete(g:GTween = null):void {
			hided.dispatch(this);
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
			const SHIFT_MULTIPLIER:int = 5;
			var shiftX:int = this.shiftX * SHIFT_MULTIPLIER;
			var shiftY:int;
			var linlen:int = line.length - 2;
			while(i <= linlen && l < length) {
				x = line[i];
				y = line[i + 1];
				var dist:int = 0;
				shiftY = i == 0 || i == linlen ? 0 : this.shiftY * SHIFT_MULTIPLIER;
				if(i == 0){
					graphics.clear();
					configurateLine();
					graphics.moveTo(x + shiftX, y + shiftY);
				}else{
					var dx:int = x - lastX;
					var dy:int = y - lastY;
					dist = Math.sqrt(dx * dx + dy * dy);
					if(l + dist > length){
						var r:Number = (length - l) / dist;
						x = lastX + dx * r;
						y = lastY + dy * r;
					}
					if(dashed){
						const dashSize:int = 5;
						var rdist:Number = Math.sqrt(Math.pow(x - lastX, 2) + Math.pow(y - lastY, 2))
						var rx:Number = (x - lastX) / rdist;
						var ry:Number = (y - lastY) / rdist;
						var _x:Number = lastX;
						var _y:Number = lastY;
						var _dist:Number = 0;
						while(_dist < rdist){
							graphics.moveTo(_x + shiftX, _y + shiftY);
							_x += rx * dashSize; _y += ry * dashSize;
							graphics.lineTo(_x + shiftX, _y + shiftY);
							_x += rx * dashSize; _y += ry * dashSize;
							_dist += dashSize * 2;
						}
					} else
						graphics.lineTo(x + shiftX, y + shiftY);
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
