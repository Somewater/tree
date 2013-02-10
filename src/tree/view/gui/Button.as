package tree.view.gui {
	import com.somewater.text.EmbededTextField;

	import flash.display.MovieClip;

	import tree.view.gui.UIComponent;

	public class Button extends UIComponent{

		protected var _movie:MovieClip;
		protected var upFrame:int = 0;
		protected var overFrame:int = 0;
		protected var downFrame:int = 0;

		private var _textField:EmbededTextField;
		private var _label:String = '';

		public function Button(movie:MovieClip = null) {
			if(movie)
				this.movie = movie;

			over.add(onOver);
			out.add(onOut);
			down.add(onDown);
			up.add(onUp);

			useHandCursor = buttonMode = true;
			tabEnabled = false;
		}

		public function get movie():MovieClip {
			return _movie;
		}

		public function set movie(value:MovieClip):void {
			if(_movie)
				_movie.parent.removeChild(_movie);
			_movie = value;
			addChildAt(_movie, 0);

			if(_movie.totalFrames >= 3){
				upFrame = 1;
				overFrame = 2;
				downFrame = 3;
			}else if(_movie.totalFrames == 2){
				upFrame = 1;
				overFrame = 2;
				downFrame = 0;
			}else{
				overFrame = downFrame = 0;
				upFrame = 1;
			}

			toFrame(upFrame);
		}

		private function onOver(b:Button):void{
			if(overFrame)
				toFrame(overFrame);
		}

		private function onOut(b:Button):void{
			if(upFrame)
				toFrame(upFrame);
		}

		private function onDown(b:Button):void{
			if(downFrame)
				toFrame(downFrame);
		}

		private function onUp(b:Button):void{
			if(overFrame)
				toFrame(overFrame);
		}

		protected function toFrame(frame:int):void{
			if(_movie)
				_movie.gotoAndStop(frame);
		}


		public function get label():String {
			return _label;
		}

		public function set label(value:String):void {
			_label = value;
			if(_textField)
				_textField.text = _label;
			refresh();
		}

		override protected function refresh():void {
			if(_textField){
				_textField.x = (this.width - _textField.textWidth) * 0.5;
				_textField.y = (this.height - _textField.height) * 0.5;
			}
		}

		public function get textField():EmbededTextField {
			return _textField;
		}

		public function set textField(value:EmbededTextField):void {
			if(_textField)
				_textField.parent.removeChild(_textField);
			_textField = value;
			if(_textField)
				addChild(_textField);
			refresh();
		}


		override public function get width():Number {
			return _movie ? _movie.width : super.width;
		}


		override public function get height():Number {
			return _movie ? _movie.height : super.height;
		}
	}
}
