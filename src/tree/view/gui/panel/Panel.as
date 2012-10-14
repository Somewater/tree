package tree.view.gui.panel {
	import com.somewater.storage.I18n;
	import com.somewater.text.EmbededTextField;
	import com.somewater.text.LinkLabel;

	import flash.display.DisplayObject;
	import flash.display.Shape;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;

	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;

	import tree.common.Config;
	import tree.model.Person;

	import tree.view.gui.Button;
	import tree.view.gui.UIComponent;

	public class Panel extends Sprite{

		private var background:Sprite;
		public var titleTF:EmbededTextField;
		public var treeOwnerNameTF:LinkLabel;
		public var treeOwnerMark:DisplayObject;
		public var savePrintButton:DoubleButton;
		public var centreRotateButton:DoubleButton;
		public var optionsButton:Button;
		public var fullscreenButton:Button;
		public var depthSelector:DepthSelector;
		public var zoomSlider:ZoomSlider;
		public var saveTreeButton:BlueButton;

		public var ownerNameClick:ISignal;
		public var treeSelectorPopup:TreeSelectorPopup;
		private var treeSelectorPopupMask:Shape = new Shape();

		private var mouseOverPanel:Boolean = false;

		public function Panel() {
			background = new Sprite();
			addChild(background);
			alpha = 0.5;

			titleTF = new EmbededTextField(null, 0, 19, true);
			titleTF.text = I18n.t('FAMILY');
			addChild(titleTF);

			treeOwnerNameTF = new LinkLabel(null,0x2682c5, 19, true);
			addChild(treeOwnerNameTF);
			treeOwnerNameTF.addEventListener(LinkLabel.LINK_CLICK, onLinkClicked);
			ownerNameClick = new Signal();
			treeOwnerMark = Config.loader.createMc('assets.TriangleMarkLink');
			treeOwnerMark.rotation = 180;
			addChild(treeOwnerMark);

			savePrintButton = new DoubleButton(Config.loader.createMc('assets.SaveButton'), Config.loader.createMc('assets.PrintButton'));
			addChild(savePrintButton);

			centreRotateButton = new DoubleButton(Config.loader.createMc('assets.CentreButton'), Config.loader.createMc('assets.RotateButton'));
			addChild(centreRotateButton);

			optionsButton = new Button(Config.loader.createMc('assets.OptionsButton'));
			addChild(optionsButton);

			fullscreenButton = new Button(Config.loader.createMc('assets.FullscreenButton'));
			addChild(fullscreenButton);

			depthSelector = new DepthSelector();
			addChild(depthSelector);

			zoomSlider = new ZoomSliderComponent();
			addChild(zoomSlider);

			saveTreeButton = new BlueButton();
			saveTreeButton.width = 160;
			addChild(saveTreeButton);
			saveTreeButton.label = I18n.t('SAVE_TREE');

			treeSelectorPopup = new TreeSelectorPopup();
			Config.tooltips.addChild(treeSelectorPopup);
			treeSelectorPopup.visible = false;
			treeSelectorPopup.alpha = 0;

			treeSelectorPopupMask = new Shape();
			addChild(treeSelectorPopupMask);
			treeSelectorPopup.mask = treeSelectorPopupMask;


			this.addEventListener(MouseEvent.ROLL_OVER, onMouseOver);
			this.addEventListener(MouseEvent.ROLL_OUT, onMouseOut);
		}

		private function onLinkClicked(event:Event):void {
			ownerNameClick.dispatch();
		}

		public function setSize(w:int, h:int):void {
			background.graphics.clear();
			background.graphics.beginFill(0xEEEEEE);
			background.graphics.drawRect(0, 0, Config.WIDTH, h);

			titleTF.x = 30;
			titleTF.y = 15;
			refreshOwnerName();

			saveTreeButton.x = w - 30 - saveTreeButton.width;
			saveTreeButton.y = 15;

			var nextX:int = 30;
			var nextY:int = 65;
			var components:Array = [depthSelector, savePrintButton, centreRotateButton, zoomSlider, optionsButton, fullscreenButton]

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

		public function setOwner(owner:Person = null):void {
			treeOwnerNameTF.text = owner ? owner.name : '...';
			refreshOwnerName();
		}

		private function refreshOwnerName():void {
			treeOwnerNameTF.x = titleTF.x + titleTF.width + 10;
			treeOwnerNameTF.y = titleTF.y;

			treeOwnerMark.x = treeOwnerNameTF.x + treeOwnerNameTF.width + 10;
			treeOwnerMark.y = treeOwnerNameTF.y + treeOwnerNameTF.height * 0.5;

			treeSelectorPopupMask.x = treeSelectorPopup.openedX = treeSelectorPopup.x = treeOwnerNameTF.x;
			treeSelectorPopupMask.y = treeSelectorPopup.openedY = treeSelectorPopup.y = treeOwnerNameTF.y + treeOwnerNameTF.height;

			treeSelectorPopupMask.graphics.clear();
			treeSelectorPopupMask.graphics.beginFill(0);
			treeSelectorPopupMask.graphics.drawRect(-10, -10, 300, Config.HEIGHT);
		}

		public function utilize():void {
			setOwner(null)
		}

		private function onMouseOver(event:MouseEvent):void {
			alpha = 1;
			background.alpha = 0.75;
			mouseOverPanel = true;
		}

		private function onMouseOut(event:MouseEvent):void {
			alpha = 0.5;
			background.alpha = 1;
			mouseOverPanel = false;
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

class ZoomSliderComponent extends ZoomSlider{

	private var model:Model;

	public function ZoomSliderComponent(){
		super();

		model = Config.inject(Model) as Model;
		model.bus.zoom.add(onZoomChanged);
		changed.add(onValueChanged);

		this.value = model.zoom;
		thumb.y = 2;
	}

	private function onZoomChanged(zoom:Number):void {
		value = zoom;
	}

	private function onValueChanged(value:Number):void {
		var canvas:DisplayObject = Config.inject(Canvas);
		model.zoomCenter = canvas.globalToLocal(new Point(model.contentWidth * 0.5,
															(Config.HEIGHT - Config.PANEL_HEIGHT) * 0.5));
		model.zoom = value;
	}
}
