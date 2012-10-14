package tree.view.gui.profile {
	import com.somewater.display.CorrectSizeDefinerSprite;
	import com.somewater.storage.I18n;
	import com.somewater.text.EmbededTextField;

	import fl.containers.ScrollPane;
	import fl.controls.ScrollPolicy;

	import flash.display.Sprite;

	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;

	import tree.model.Join;

	import tree.model.Person;
	import tree.view.gui.UIComponent;

	public class FamilyBlock extends UIComponent{

		private var familyLabel:EmbededTextField;
		private var scroller:ScrollPane;
		private var itemsHolder:Sprite;
		private var items:Array = [];

		private var _maxHeight:int;

		public var itemClick:ISignal = new Signal(Person);

		public function FamilyBlock() {
			familyLabel = new EmbededTextField(null, 0, 17);
			familyLabel.text = I18n.t('FAMILY');
			addChild(familyLabel);

			scroller = new ScrollPane();
			scroller.y = familyLabel.y + familyLabel.height + 5;
			scroller.horizontalScrollPolicy = ScrollPolicy.OFF;
			addChild(scroller);

			itemsHolder = new CorrectSizeDefinerSprite();
			scroller.source = itemsHolder;
		}

		override public function clear():void {
			super.clear();
			clearItems();
			itemClick.removeAll();
		}

		public function setPerson(person:Person, editable:Boolean):void {
			clearItems();

			var i:FamilyBlockItem;
			var nextY:int = 0;
			for each(var j:Join in person.joins)
			{
				i = new FamilyBlockItem();
				i.data = j;
				i.click.add(onItemClicked);
				itemsHolder.addChild(i);
				i.y = nextY;
				nextY += i.height;
				items.push(i);
			}
			if(i)
				scroller.verticalLineScrollSize = i.height * 3;
			itemsHolder.graphics.clear()
			itemsHolder.graphics.beginFill(0,0);
			itemsHolder.graphics.drawRect(0,0,width,nextY)
			refresh();
		}

		override protected function refresh():void {
			super.refresh();

			scroller.setSize(_width, Math.max(30,_maxHeight - 10 - scroller.y));
			scroller.update();

			var _height:int = calculatedHeight;
			graphics.clear();
			graphics.lineStyle(1, 0xC2DA75);
			graphics.moveTo(0,0);
			graphics.lineTo(_width, 0);
			graphics.moveTo(0,_height - 1);
			graphics.lineTo(_width, _height - 1);
			graphics.lineStyle(1, 0xECF4CF);
			graphics.moveTo(0,1);
			graphics.lineTo(_width, 1);
			graphics.moveTo(0,_height);
			graphics.lineTo(_width, _height);
		}

		private function clearItems():void{
			for each(var i:FamilyBlockItem in items){
				i.clear();
				i.parent.removeChild(i);
			}
			items = [];
		}

		private function onItemClicked(item:FamilyBlockItem):void{
			itemClick.dispatch(item.data.associate);
		}

		public function set maxHeight(value:int):void{
			_maxHeight = value;
			refresh();
		}

		override public function get calculatedHeight():int {
			return Math.min(scroller.y + itemsHolder.height + 10, scroller.y + scroller.height + 10);
		}
	}
}
