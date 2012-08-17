package tree.view.gui.panel {
	import flash.display.DisplayObject;
	import flash.display.Sprite;

	import tree.common.Config;
	import tree.manager.ITick;

	import tree.view.gui.UIComponent;
	import tree.view.gui.Button;

	public class ZoomSlider extends UIComponent implements ITick{

		private var line:DisplayObject;
		private var thumb:Button;
		private var holder:Sprite;

		private const POSITIONS:Array = [0, 36, 72, 108, 144, 181];

		public function ZoomSlider() {
			holder = new Sprite();
			addChild(holder);


			line = Config.loader.createMc('assets.ZoomSliderLine');
			holder.addChild(line);

			thumb = new Button(Config.loader.createMc('assets.ZoomSliderThumb'));
			holder.addChild(thumb);

			holder.x = thumb.width * 0.5;
			holder.y = thumb.height * 0.25 + 5;
		}


		override public function clear():void {
			super.clear();
			thumb.clear();
			Config.ticker.remove(this);
		}

		public function tick(deltaMS:int):void {
		}


		override public function get width():Number {
			return thumb.width + line.width;
		}
	}
}
