package tree.view.canvas {
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;

	import tree.common.Config;

	import tree.common.IClear;
	import tree.loader.Lib;

	public class RollUnrollButton extends Sprite implements IClear{

		private var movie:MovieClip;

		private var _rollState:Boolean = false;// в состоянии развернуто

		private var over:Boolean;
		private var down:Boolean;
		private var out:Boolean = true;
		private var _male:Boolean;

		public function RollUnrollButton() {
			movie = Config.loader.createMc('assets.RollUnrollButton');
			addChild(movie);
			buttonMode = useHandCursor = true;
			movie.stop();
			refresh();

			addEventListener(MouseEvent.MOUSE_OVER, onOver);
			addEventListener(MouseEvent.MOUSE_OUT, onOut);
			addEventListener(MouseEvent.MOUSE_DOWN, onDown);
			addEventListener(MouseEvent.MOUSE_UP, onUp);
		}

		private function onUp(event:MouseEvent):void {
			over = true;
			down = out = false;
			refresh();
		}

		private function onDown(event:MouseEvent):void {
			down = true;
			over = out = false;
			refresh();
		}

		private function onOut(event:MouseEvent):void {
			out = true;
			down = over = false;
			refresh();
		}

		private function onOver(event:MouseEvent):void {
			over = true;
			down = out = false;
			refresh();
		}

		public function clear():void {
			removeEventListener(MouseEvent.MOUSE_OVER, onOver);
			removeEventListener(MouseEvent.MOUSE_OUT, onOut);
			removeEventListener(MouseEvent.MOUSE_DOWN, onDown);
			removeEventListener(MouseEvent.MOUSE_UP, onUp);
		}

		private function refresh():void{
			var frame:int = _rollState ? 0 : 3;
			if(over) frame += 1; else if(down) frame += 2;
			if(!_male)frame += 6;
			movie.gotoAndStop(frame + 1)
		}

		public function get male():Boolean {
			return _male;
		}

		public function set male(value:Boolean):void {
			_male = value;
			refresh();
		}

		public function get rollState():Boolean {
			return _rollState;
		}

		public function set rollState(value:Boolean):void {
			if(_rollState != value){
				_rollState = value;
				refresh();
			}
		}
	}
}
