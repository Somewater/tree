package tree.view.gui.panel {
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

	import tree.view.gui.UIComponent;

	public class TreeSelectorPopup extends UIComponent{

		private var ground:DisplayObject;
		private var labelsHolder:Sprite;
		private var scroller:ScrollPane = new ScrollPane();

		public var linkClick:ISignal;// (person:Person)

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

		public function refreshData(data:Array):void {
			var l:LinkLabel

			while(labelsHolder.numChildren){
				l = labelsHolder.removeChildAt(0) as LinkLabel;
				l.clear();
				l.removeEventListener(LinkLabel.LINK_CLICK, onLInkClicked);
				l.data = null;
			}

			var nextY:int = 0;
			for each(var p:Person in data){
				l = new LinkLabel(null, 0x2781C8, 13);
				l.text = p.name;
				l.data = p;
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
	}
}
