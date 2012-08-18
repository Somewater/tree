package tree.view.gui.panel {
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;

	import tree.common.Config;
	import tree.manager.ITick;

	import tree.view.gui.UIComponent;
	import tree.view.gui.Button;

	public class ZoomSlider extends UIComponent{

		private var line:DisplayObject;
		private var thumb:Button;
		private var thumbDragged:Boolean = false;
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

			thumb.down.add(onThumbDown);
			thumb.up.add(onThumbUp);
			down.add(onDown);
			out.add(onThumbUp);
		}


		override public function clear():void {
			super.clear();
			thumb.clear();
		}

		public function tick(deltaMS:int):void {
		}


		override public function get width():Number {
			return thumb.width + line.width;
		}

		private function onThumbDown(b:ZoomSlider):void{
			if(!thumbDragged){
				thumbDragged = true;
				Config.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMove);
			}
		}

		private function onThumbUp(b:ZoomSlider):void{
			if(thumbDragged){
				thumbDragged = false;
				Config.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMove);
			}
		}

		private function onDown(b:ZoomSlider):void{
			if(!thumbDragged){

			}
		}

		private function onMove(event:MouseEvent):void {
		}
	}
}
