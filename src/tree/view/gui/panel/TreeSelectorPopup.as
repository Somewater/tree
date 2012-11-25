package tree.view.gui.panel {
	import com.gskinner.motion.GTween;
	import com.somewater.display.CorrectSizeDefinerSprite;
	import com.somewater.text.LinkLabel;
	import com.somewater.text.LinkLabel;

	import fl.containers.ScrollPane;
	import fl.controls.ScrollPolicy;

	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;

	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;

	import tree.common.Config;
	import tree.model.Person;
import tree.model.TreeModel;
import tree.view.Tweener;
	import tree.view.gui.IShowable;

	import tree.view.gui.UIComponent;

	public class TreeSelectorPopup extends UIComponent implements IShowable{

		private var ground:DisplayObject;
		private var labelsHolder:Sprite;
		private var scroller:ScrollPane = new ScrollPane();

		public var linkClick:ISignal;// (person:Person)

		public var openedX:int;
		public var openedY:int;

		public function TreeSelectorPopup() {
			ground = Config.loader.createMc('assets.OwnerNamePopupGround');
			addChild(ground);

			scroller = new ScrollPane();
			scroller.x = 15;
			scroller.y = 15;
			scroller.horizontalScrollPolicy = ScrollPolicy.OFF;
			addChild(scroller);

			labelsHolder = new CorrectSizeDefinerSprite();
			scroller.source = labelsHolder;
			scroller.verticalLineScrollSize = 24 * 10;

			linkClick = new Signal(Person);
		}

		public function refreshData(trees:Array):void {
			var l:LinkLabel

			while(labelsHolder.numChildren){
				l = labelsHolder.removeChildAt(0) as LinkLabel;
				l.clear();
				l.removeEventListener(LinkLabel.LINK_CLICK, onLInkClicked);
				l.data = null;
			}

			var nextY:int = 0;
			for each(var t:TreeModel in trees){
				l = new LinkLabel(null, 0x2781C8, 13);
				l.text = t.name;
				l.data = t.owner;
				l.y = nextY;
				l.addEventListener(LinkLabel.LINK_CLICK, onLInkClicked);
				nextY += 24//l.textField.textHeight + 5;
				labelsHolder.addChild(l);
			}

			labelsHolder.graphics.beginFill(0,0);
			labelsHolder.graphics.drawRect(0,0,200,nextY)

			setSize(200, Math.min(nextY + scroller.y + 10, 500, Config.HEIGHT - this.y - 15))
		}

		override protected function refresh():void {
			ground.width = _width;
			ground.height = _height;
			scroller.setSize(_width - scroller.x - 5, _height - scroller.y - 10);
			scroller.update();
		}

		private function onLInkClicked(event:Event):void {
			var l:LinkLabel = event.currentTarget as LinkLabel;
			var person:Person = l.data as Person;
			linkClick.dispatch(person);
		}

		public function show():void {
			this.y = -this.calculatedHeight;
			this.alpha = 0.3;
			this.visible = true;
			Tweener.to(this, 0.3, {y: openedY, alpha: 1});
		}

		public function hide():void {
			Tweener.to(this, 0.3, {y: -this.calculatedHeight, alpha: 0.3}, {onComplete: onHideComplete});
		}

		private function onHideComplete(g:GTween = null):void {
			this.visible = false;
		}
	}
}
