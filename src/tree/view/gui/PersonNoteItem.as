package tree.view.gui {
	import com.gskinner.motion.GTweener;
	import com.somewater.storage.I18n;
	import com.somewater.text.LinkLabel;
	import com.somewater.text.TruncatedTextField;

	import flash.display.DisplayObject;

	import flash.display.Sprite;

	import tree.common.Config;

	import tree.common.IClear;
	import tree.model.Join;

	public class PersonNoteItem extends Sprite implements ISize, IClear{

		private var _data:Join;
		private var nameTF:TruncatedTextField;
		private var postTF:TruncatedTextField;
		private var actionsTF:LinkLabel;

		private var bottomBorder:DisplayObject;
		private var _selected:Boolean = false;
		private var _opened:Boolean = false;
		private var newItem:Boolean = true;

		public function PersonNoteItem() {
			nameTF = new TruncatedTextField(null, 0x799919, 15, true);
			nameTF.maxWidth = 225;
			nameTF.x = 14;
			nameTF.y = 12;
			addChild(nameTF);

			postTF = new TruncatedTextField(null, 0x799919, 15, true);
			postTF.maxWidth = 225;
			postTF.x = nameTF.x;
			postTF.y = 35;
			addChild(postTF);

			actionsTF = new LinkLabel(null, 0, 13, true);
			actionsTF.text = I18n.t('ACTIONS')
			actionsTF.x = Config.GUI_WIDTH - 15 - actionsTF.width;
			actionsTF.y = postTF.y;
			addChild(actionsTF);

			bottomBorder = Config.loader.createMc('assets.GuiElementHRile');
			bottomBorder.y = PersonNotesPage.NOTE_HEIGHT;
			addChildAt(bottomBorder, 0);

			this.visible = false;
		}

		public function get calculatedHeight():int {
			return _opened ? 300 : PersonNotesPage.NOTE_HEIGHT;
		}

		public function clear():void {
			actionsTF.clear();
			_data = null;
		}

		public function set data(data:Join):void {
			_data = data;
			nameTF.text = data.associate.name;
			postTF.text = data.type.toString();
			refresh();
		}

		public function get data():Join{
			return _data;
		}

		private function refresh():void {
		}


		public function get selected():Boolean {
			return _selected;
		}

		public function set selected(value:Boolean):void {
			if(_selected != value){
				_selected = value;
			}
		}

		public function get opened():Boolean {
			return _opened;
		}

		public function set opened(value:Boolean):void {
			if(_opened != value){
				_opened = value;
			}
		}

		public function moveTo(y:int):void {
			if(newItem){
				this.visible = true;
				this.y = y;
				alpha = 0;
				GTweener.to(this, PersonNotesPage.CHANGE_TIME, {alpha: 1})
			}else
				GTweener.to(this, PersonNotesPage.CHANGE_TIME, {y: y});
			newItem = false;
		}
	}
}
