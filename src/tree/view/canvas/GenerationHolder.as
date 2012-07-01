package tree.view.canvas {
	import flash.display.Sprite;
	import flash.geom.Point;

	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;

	import tree.common.Config;

	import tree.common.IClear;
	import tree.view.canvas.GenerationHolder;

	public class GenerationHolder extends Sprite implements IClear{


		public var generation:int;
		public var odd:Boolean;

		public var changed:ISignal;

		private var _levels:int
		private var nodesByUid:Array = [];

		public function GenerationHolder(generation:int) {
			this.generation = generation;
			this.odd = (generation % 2) == 0;

			changed = new Signal(GenerationHolder);
		}

		public function clear():void {
		}

		public function addNode(icon:NodeIcon):void {
			var lastLevels:int = _levels;

			addChild(icon);
			nodesByUid[icon.data.uid] = icon;
			recalculateLevels();

			if(lastLevels != _levels)
				draw();
		}

		public function removeNode(icon:NodeIcon):void {
			var lastLevels:int = _levels;

			removeChild(icon);
			delete(nodesByUid[icon.data.uid]);
			recalculateLevels();

			if(lastLevels != _levels)
				draw();
		}

		private function recalculateLevels():void {
			var levelsHash:Array = [];
			_levels = 0;
			for each(var icon:NodeIcon in nodesByUid) {
				if(!levelsHash[icon.data.level])
				{
					levelsHash[icon.data.level] = true;
					_levels++;
				}
			}
		}

		private function fireChange():void {
			changed.dispatch(this);
		}

		private function draw():void {
			graphics.clear();
			graphics.beginFill(odd ? 0xFEFEFC : 0xFAFAF8);
			graphics.drawRect(Config.WIDTH * -2, 0, Config.WIDTH * 4, _levels * Canvas.LEVEL_HEIGHT);
		}

		public function get levels():int {
			return _levels;
		}
	}
}
