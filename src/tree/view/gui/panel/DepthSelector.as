package tree.view.gui.panel {
	import com.somewater.storage.I18n;

	import flash.display.DisplayObject;
	import flash.display.Sprite;

	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;

	import tree.common.Config;
	import tree.model.Model;
	import tree.view.Tweener;

	import tree.view.gui.UIComponent;

	public class DepthSelector extends UIComponent{

		private static const LABELS:Array = ['DEPTH_ALL', 'DEPTH_PARENTS', 'DEPTH_BRO'];
		private static const PADDING:int = 5;

		private var ground:DisplayObject;
		private var thumb:Thumb;
		private var labelsHolder:Sprite;
		private var _index:int = 0;

		public var indexChanged:ISignal = new Signal(int);

		public function DepthSelector() {
			ground = Config.loader.createMc('assets.DepthSelectorGround');
			addChild(ground);

			thumb = new Thumb();
			addChild(thumb);

			labelsHolder = new Sprite();
			addChild(labelsHolder);

			createLabels();
		}

		private function createLabels():void{
			var index:int = 0;
			var nextX:int = PADDING;
			for each(var lbl:String in LABELS){
				var l:Label = new Label(I18n.t(lbl), index);
				labelsHolder.addChild(l);
				l.click.add(onLabelClicked);
				l.x = nextX;
				l.y = PADDING;
				nextX += l.width + PADDING;
				index++;
			}

			ground.width = nextX + PADDING;
			thumb.y = PADDING * 0.5;

			_index = -1
			this.index = Model.instance.depthIndex;
		}

		private function onLabelClicked(index:int):void{
			indexChanged.dispatch(index);
		}

		public function get index():int {
			return _index;
		}

		public function set index(value:int):void {
			if(_index != value){
				_index = value;
				for (var i:int = 0; i < labelsHolder.numChildren; i++) {
					var l:Label = labelsHolder.getChildAt(i) as Label;
					var selected:Boolean = l.index == value;
					l.selected = selected;
					if(selected){
						thumb.setSize(l.width + PADDING);
						Tweener.to(thumb, 0.3, {x: l.x - PADDING * 0.5})
					}
				}
			}
		}
	}
}

import com.somewater.text.EmbededTextField;
import com.somewater.text.LinkLabel;

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.Event;

import org.osflash.signals.ISignal;
import org.osflash.signals.Signal;

import tree.common.Config;

class Thumb extends Sprite{

	private var ground:DisplayObject;
	private var mark:DisplayObject

	public function Thumb(){
		mark = Config.loader.createMc('assets.DepthSelectorThumbMark')
		addChild(mark);

		ground = Config.loader.createMc('assets.DepthSelectorThumb');
		addChild(ground);
	}

	public function setSize(w:int, h:int = 21):void{
		ground.width = w;
		ground.height = h;
		mark.x = w * 0.5;
		mark.y = h;
	}
}

class Label extends LinkLabel{

	public var index:int;
	public var click:ISignal = new Signal(int)

	public function Label(text:String, index:int){
		super(null, 0x2881C6, 11);

		this.text = text;
		this.index = index;

		addEventListener(LinkLabel.LINK_CLICK, onClick);
	}

	private function onClick(event:Event):void {
		click.dispatch(index);
	}

	public function set selected(value:Boolean):void{
		textField.color = value ? 0xFFFFFF : 0x2881C6;
		linked = !value;
	}
}
