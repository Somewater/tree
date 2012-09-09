package tree.view.gui {
	import com.somewater.text.EmbededTextField;

	import tree.common.Config;

	public class StandartButton extends Button{
		public function StandartButton() {
			super(Config.loader.createMc('assets.StandartButtonGround'));
			textField = new EmbededTextField(null, 0xFFFFFF, 11, true);
		}


		override protected function refresh():void {
			movie.width = _width;
			movie.height = _height;
			if(textField)
				textField.width = _width;
			super.refresh();
		}
	}
}
