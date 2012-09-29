package tree.view.gui.panel {
	import com.gskinner.motion.GTweener;

	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;

	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;

	import tree.common.Config;
	import tree.manager.ITick;
	import tree.view.Tweener;

	import tree.view.gui.UIComponent;
	import tree.view.gui.Button;

	public class ZoomSlider extends UIComponent{

		private var line:DisplayObject;
		protected var thumb:Button;
		private var thumbDragged:Boolean = false;
		private var holder:Sprite;
		private var dragStartMousePos:Point = new Point();
		private var dragStartThumbPos:Point = new Point();

		private const POSITIONS:Array = [0, 36, 72, 108, 144, 181];
		public var changed:ISignal;
		private var thumbX:Number = 0;

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
			click.add(onClick);

			changed = new Signal(Number);

			graphics.beginFill(0, 0);
			graphics.drawRect(0, 0, line.width + thumb.width, thumb.height)
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

		private function onThumbDown(b:UIComponent):void{
			if(!thumbDragged){
				thumbDragged = true;
				Config.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMove);
				dragStartMousePos.x = this.mouseX;
				dragStartMousePos.y = this.mouseY;
				dragStartThumbPos.x = thumbX;
				dragStartThumbPos.y = thumb.y;
			}
		}

		private function onThumbUp(b:UIComponent):void{
			if(thumbDragged){
				thumbDragged = false;
				Config.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMove);
			}
		}

		private function onDown(b:UIComponent):void{
			if(!thumbDragged){

			}
		}

		private function onMove(event:MouseEvent):void {
			var oldValue:Number = this.value;
			var dx:int = this.mouseX - dragStartMousePos.x;
			var dy:int = this.mouseY - dragStartMousePos.y;
			dx = dx + dragStartThumbPos.x;
			setNearestCoord(dx);

			var newValue:Number = this.value;
			if(oldValue != newValue)
				changed.dispatch(newValue);
		}

		public function get value():Number{
			var maxVal:int = POSITIONS[POSITIONS.length - 1];
			return thumbX / maxVal;
		}

		public function set value(v:Number):void{
			setNearestCoord(POSITIONS[POSITIONS.length - 1] * v);
		}

		private function setNearestCoord(x:int):void{
			var minD:int = int.MAX_VALUE;
			var selectedX:int = 0;
			for each(var p:int in POSITIONS){
				if(Math.abs(x - p) < minD){
					minD = Math.abs(x - p);
					selectedX = p;
				}
			}
			thumbX = selectedX;
			Tweener.to(thumb, 0.2, {x: selectedX});
		}

		private function onClick(u:UIComponent):void{
			var oldValue:Number = this.value;
			setNearestCoord(this.mouseX - holder.x);

			var newValue:Number = this.value;
			if(oldValue != newValue)
				changed.dispatch(newValue);
		}
	}
}
