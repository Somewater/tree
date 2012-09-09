package tree.view.gui.profile {
	import com.somewater.display.CorrectSizeDefinerSprite;
	import com.somewater.storage.I18n;
	import com.somewater.text.EmbededTextField;

	import fl.containers.ScrollPane;

	import flash.display.Sprite;

	import tree.model.Join;

	import tree.model.Person;
	import tree.view.gui.UIComponent;

	public class FamilyBlock extends UIComponent{

		private var familyLabel:EmbededTextField;
		private var scroller:ScrollPane;
		private var itemsHolder:Sprite;
		private var items:Array = [];

		private var _maxHeight:int;

		public function FamilyBlock() {
			familyLabel = new EmbededTextField(null, 0, 17);
			familyLabel.text = I18n.t('FAMILY');
			addChild(familyLabel);

			scroller = new ScrollPane();
			scroller.y = familyLabel.y + familyLabel.height + 5;
			addChild(scroller);

			itemsHolder = new CorrectSizeDefinerSprite();
			scroller.source = itemsHolder;
		}

		override public function clear():void {
			super.clear();
			clearItems();
		}

		public function setPerson(person:Person):void {
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
			refresh();
		}

		override protected function refresh():void {
			super.refresh();

			scroller.setSize(_width, _maxHeight);
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
