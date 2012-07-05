package tree.view.canvas {
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;

	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;

	import tree.common.Config;

	import tree.common.IClear;
	import tree.model.GenNode;
	import tree.model.Generation;

	public class GenerationBackground extends Sprite implements IClear{


		public var generation:Generation;
		public var odd:Boolean;

		public function GenerationBackground(generation:Generation) {
			this.generation = generation;
			var genNumber:int = generation.generation;

			this.odd = (genNumber % 2) == 0;

			refresh();
		}

		public function clear():void {
		}

		public function refresh():void {
			log("G=" + generation.generation + ', y=' + generation.y);
			this.y = generation.y * Canvas.LEVEL_HEIGHT;
			graphics.clear();
			graphics.beginFill(generation.generation == 0 ? 0xccFFcc: 0xCCCCCC + this.generation.generation * 0x111111)//odd ? 0xFCFFFC : 0xFAFAF0);
			graphics.drawRect(Config.WIDTH * -2, 0, Config.WIDTH * 4, generation.levelNum * Canvas.LEVEL_HEIGHT);
		}
	}
}
