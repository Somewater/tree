package tree.view.canvas {
	import com.gskinner.motion.GTween;
	import com.gskinner.motion.GTweener;

	import flash.display.DisplayObjectContainer;

	import flash.display.Sprite;

	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;

	import tree.common.Config;

	import tree.common.IClear;
	import tree.model.Person;
	import tree.view.gui.IShowable;
	import tree.view.gui.UIComponent;

	public class NodeArrow extends UIComponent implements IClear, IShowable{

		public static const BREED:int = 1;
		public static const PARENT:int = 2;
		public static const PARALLEL:int = 3;


		public static const SIZE:int = 17;
		private var movie:DisplayObjectContainer;
		public var type:int;
		public var data:Person;

		public var showed:ISignal;
		public var hided:ISignal;

		public function NodeArrow(data:Person, type:int) {
			this.type = type;
			this.data = data;

			movie = Config.loader.createMc('assets.NodeArrow');
			addChild(movie);
			movie.getChildByName('male').visible = data.male;
			movie.getChildByName('female').visible = data.female;

			if(type == BREED){
				rotation = 90;
			}else if(type == PARENT){
				rotation = -90;
			}else if(data.male){// PARALLEL
				rotation = 180;
			}else{
				// nothing
			}

			showed = new Signal(NodeArrow);
			hided = new Signal(NodeArrow);
		}

		override public function clear():void {
			super.clear();

			GTweener.removeTweens(this);
			data = null;
			showed.removeAll();
			hided.removeAll();
		}

		public function show():void {
			animate(false);
		}

		private function onShowed(g:GTween):void {
			showed.dispatch(this);
		}

		private function onHided(g:GTween):void {
			hided.dispatch(this);
		}

		public function hide():void {
			animate(true);
		}

		private function animate(hide:Boolean):void{
			var fromX:int;
			var fromY:int;
			var toX:int;
			var toY:int;
			if(type == BREED){
				toX = Canvas.ICON_WIDTH * 0.5;
				toY = Canvas.ICON_HEIGHT - 1;
				fromX = toX;
				fromY = toY - SIZE;
			}else if(type == PARENT){
				toX = Canvas.ICON_WIDTH * 0.5;
				toY = 0;
				fromX = toX;
				fromY = toY + SIZE
			}else if(data.male){// PARALLEL
				toX = 0;
				toY = Canvas.ICON_HEIGHT * 0.5;
				fromX = toX + SIZE;
				fromY = toY;
			}else{
				toX = Canvas.ICON_WIDTH;
				toY = Canvas.ICON_HEIGHT * 0.5;
				fromX = toX - SIZE;
				fromY = toY;
			}

			if(hide){
				var buff:int;
				buff = toX; toX = fromX; fromX = buff;
				buff = toY; toY = fromY; fromY = buff;
			}else{
				this.x = fromX;
				this.y = fromY;
			}
			GTweener.to(this, 0.2, {x: toX, y: toY}, {onComplete: hide ? onHided : onShowed});
		}
	}
}