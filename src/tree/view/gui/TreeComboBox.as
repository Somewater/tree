package tree.view.gui {
	import fl.controls.ComboBox;

	import flash.display.DisplayObject;
	import flash.text.TextFieldAutoSize;

	import tree.common.Config;

	public class TreeComboBox extends ComboBox{

		private var icon:DisplayObject;

		public function TreeComboBox() {
			super();
			this.height = 28;

			icon = Config.loader.createMc('ComboBox_ArrowIcon');
			addChild(icon);

			textField.textField.autoSize = TextFieldAutoSize.LEFT;
		}

		override protected function draw():void {
			super.draw();

			icon.x = this.width - 10;
			icon.y = this.height * 0.5 - 2;
			textField.textField.width = this.width - 14;
		}
	}
}
