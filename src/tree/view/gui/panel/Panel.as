package tree.view.gui.panel {
	import com.somewater.storage.I18n;
	import com.somewater.text.EmbededTextField;

	import flash.display.Sprite;

	import tree.common.Config;

	import tree.view.gui.Button;
	import tree.view.gui.UIComponent;

	public class Panel extends Sprite{

		public var titleTF:EmbededTextField;
		public var savePrintButton:DoubleButton;
		public var centreRotateButton:DoubleButton;
		public var optionsButton:Button;
		public var fullscreenButton:Button;
		public var densitySelector:DensitySelector;
		public var zoomSlider:ZoomSlider;
		public var saveTreeButton:BlueButton;

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

			zoomSlider = new ZoomSliderComponent();
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

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.geom.Point;

import tree.common.Config;
import tree.model.Model;
import tree.view.canvas.Canvas;

import tree.view.gui.Button;
import tree.view.gui.panel.ZoomSlider;

class DoubleButton extends Button{
	public function DoubleButton(movie:MovieClip){
		super(movie);
	}

	public function onFirst():Boolean{
		return true;
	}
}

class ZoomSliderComponent extends ZoomSlider{

	private var model:Model;

	public function ZoomSliderComponent(){
		super();

		model = Config.inject(Model) as Model;
		model.bus.zoom.add(onZoomChanged);
		changed.add(onValueChanged);

		this.value = model.zoom;
	}

	private function onZoomChanged(zoom:Number):void {
		value = zoom;
	}

	private function onValueChanged(value:Number):void {
		var canvas:DisplayObject = Config.inject(Canvas);
		model.zoomCenter = canvas.globalToLocal(new Point((Config.WIDTH - Config.GUI_WIDTH) * 0.5,
															(Config.HEIGHT - Config.PANEL_HEIGHT) * 0.5));
		model.zoom = value;
	}
}
