package tree.view.canvas {
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;

	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;

	import tree.common.Config;

	import tree.common.IClear;

	public class GenerationBackground extends Sprite implements IClear{


		public var generation:int;
		private var iconsHolder:DisplayObjectContainer;
		public var odd:Boolean;

		public var changed:ISignal;

		private var _levels:int = -1;
		private var nodesByUid:Array = [];

		public function GenerationBackground(generation:int, iconsHolder:DisplayObjectContainer) {
			this.generation = generation;
			this.iconsHolder = iconsHolder;
			this.odd = (generation % 2) == 0;
			this.y = -generation * _levels * Canvas.LEVEL_HEIGHT;

			changed = new Signal(GenerationBackground);
			changed.add(draw);
		}

		public function clear():void {
		}

		public function addNode(icon:NodeIcon):void {
			var lastLevels:int = _levels;

			iconsHolder.addChild(icon);
			nodesByUid[icon.data.node.uid] = icon;
			recalculateLevels();

			if(lastLevels != _levels)
				fireChange();
		}

		public function removeNode(icon:NodeIcon):void {
			var lastLevels:int = _levels;

			iconsHolder.removeChild(icon);
			delete(nodesByUid[icon.data.node.uid]);
			recalculateLevels();

			if(lastLevels != _levels)
				fireChange();
		}

		private function recalculateLevels():void {
			var levelsHash:Array = [];
			_levels = 0;
			for each(var icon:NodeIcon in nodesByUid) {
				if(!levelsHash[icon.data.node.level])
				{
					levelsHash[icon.data.node.level] = true;
					_levels++;
				}
			}
			log('lvl=' + _levels + ', generation=' + generation)
		}

		private function fireChange():void {
			changed.dispatch(this);
		}

		private function draw(g:GenerationBackground):void {
			graphics.clear();
			graphics.beginFill(odd ? 0xFCFFFC : 0xFAFAF0);
			graphics.drawRect(Config.WIDTH * -2, 0, Config.WIDTH * 4, _levels * Canvas.LEVEL_HEIGHT);
		}

		public function get levels():int {
			return _levels;
		}
	}
}
