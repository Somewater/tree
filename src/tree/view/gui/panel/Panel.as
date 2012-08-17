package tree.view.gui.panel {
	import com.somewater.storage.I18n;
	import com.somewater.text.EmbededTextField;

	import flash.display.Sprite;

	import tree.common.Config;

	import tree.view.gui.Button;
	import tree.view.gui.UIComponent;

	public class Panel extends Sprite{

		private var titleTF:EmbededTextField;
		private var savePrintButton:DoubleButton;
		private var centreRotateButton:DoubleButton;
		private var optionsButton:Button;
		private var fullscreenButton:Button;
		private var densitySelector:DensitySelector;
		private var zoomSlider:ZoomSlider;
		private var saveTreeButton:BlueButton;

		public function Panel() {
			titleTF = new EmbededTextField(null, 0, 19, true);
			titleTF.text = 'Семья Андреева Сергея';
			addChild(titleTF);

			savePrintButton = new DoubleButton(Config.loader.createMc('assets.SavePrintButton'));
			addChild(savePrintButton);

			centreRotateButton = new DoubleButton(Config.loader.createMc('assets.CentreRotateButton'));
			addChild(centreRotateButton);

			optionsButton = new Button(Config.loader.createMc('assets.OptionsButton'));
			addChild(optionsButton);

			fullscreenButton = new Button(Config.loader.createMc('assets.FullscreenButton'));
			addChild(fullscreenButton);

			densitySelector = new DensitySelector();
			addChild(densitySelector);

			zoomSlider = new ZoomSlider();
			addChild(zoomSlider);

			saveTreeButton = new BlueButton();
			addChild(saveTreeButton);
			saveTreeButton.label = I18n.t('SAVE_TREE');
		}

		public function setSize(w:int, h:int):void {
			graphics.clear();
			graphics.beginFill(0xEEEEEE);
			graphics.drawRect(0, 0, w, h);

			titleTF.x = 30;
			titleTF.y = 15;

			saveTreeButton.x = w - 30 - saveTreeButton.width;
			saveTreeButton.y = 15;

			var nextX:int = 30;
			var nextY:int = 65;
			var components:Array = [densitySelector, savePrintButton, centreRotateButton, zoomSlider, optionsButton, fullscreenButton]

			for each(var c:UIComponent in components){
				if(nextX + c.width < w){
					c.visible = true;
					c.x = nextX;
					c.y = nextY;
					nextX += c.width + 10;
				}else{
					c.visible = false;
				}
			}
		}
	}
}

import flash.display.MovieClip;

import tree.view.gui.Button;

class DoubleButton extends Button{
	public function DoubleButton(movie:MovieClip){
		super(movie);
	}

	public function onFirst():Boolean{
		return true;
	}
}
