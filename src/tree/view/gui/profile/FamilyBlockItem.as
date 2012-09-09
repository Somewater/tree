package tree.view.gui.profile {
	import com.somewater.storage.I18n;
	import com.somewater.text.EmbededTextField;
	import com.somewater.text.LinkLabel;

	import tree.model.Join;

	import tree.view.gui.UIComponent;

	public class FamilyBlockItem extends UIComponent{
		private var _data:Join;
		private var labelTF:EmbededTextField;
		private var nameTF:LinkLabel;


		public function FamilyBlockItem() {
			labelTF = new EmbededTextField(null, 0, 11);
			addChild(labelTF);

			nameTF = new LinkLabel(null, 0x2881C6, 11);
			nameTF.x = 80;
			addChild(nameTF);
		}

		override public function clear():void {
			super.clear();
			nameTF.clear();
			_data = null
		}

		public function set data(data:Join):void {
			_data = data;
			labelTF.text = I18n.t(data.name.toUpperCase());
			nameTF.text = data.associate.name;
		}

		public function get data():Join{
			return _data;
		}
	}
}
