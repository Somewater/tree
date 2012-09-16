package tree.view.gui.profile {
	import com.somewater.storage.I18n;
	import com.somewater.text.LinkLabel;

	import tree.view.gui.Button;
	import tree.view.gui.StandartButton;
	import tree.view.gui.UIComponent;

	public class SaveButtonBlock extends UIComponent{

		internal var createProfileButton:Button;
		internal var saveProfileButton:Button;
		internal var cancelEditLink:LinkLabel;

		public function SaveButtonBlock() {
			createProfileButton = new StandartButton();
			createProfileButton.label = I18n.t('CREATE_NEW_PROFILE');
			addChild(createProfileButton);

			saveProfileButton = new StandartButton();
			saveProfileButton.label = I18n.t('SAVE_PROFILE');
			addChild(saveProfileButton);

			cancelEditLink = new LinkLabel(null, 0x2881C6, 11, true);
			cancelEditLink.text = I18n.t('CANCEL_EDIT');
			addChild(cancelEditLink);
		}

		override public function clear():void {
			super.clear();
			createProfileButton.clear();
			saveProfileButton.clear();
			cancelEditLink.clear();
		}

		public function set editable(editable:Boolean):void {
			createProfileButton.visible = !editable;
			saveProfileButton.visible = editable;
			cancelEditLink.visible = editable;
		}

		override protected function refresh():void {
			createProfileButton.setSize(_width, 27);
			saveProfileButton.setSize(_width, 27);
			cancelEditLink.x = (width - cancelEditLink.width)* 0.5;
			cancelEditLink.y = saveProfileButton.y + saveProfileButton.height + 10;
		}


		override public function get calculatedHeight():int {
			return cancelEditLink.visible ? cancelEditLink.y + cancelEditLink.height : createProfileButton.y + createProfileButton.height;
		}
	}
}
