package tree.view.gui.profile {
	import com.somewater.storage.I18n;
	import com.somewater.text.EmbededTextField;

	import tree.model.Person;

	import tree.view.gui.UIComponent;
	import tree.view.gui.profile.PersonProfilePage;

	public class ReadonlyInfo extends UIComponent{

		private var nameTF:EmbededTextField;
		private var birthdayTF:EmbededTextField;

		public function ReadonlyInfo() {
			nameTF = new EmbededTextField(null, 0, 17, true, true);
			addChild(nameTF);

			birthdayTF = new EmbededTextField(null, 0x5B5B5B, 13);
			addChild(birthdayTF);
		}

		override public function clear():void {
			super.clear();
		}

		public function setPerson(person:Person):void {
			nameTF.text = person.fullname;
			birthdayTF.text = I18n.t('BIRTHDAY_LABEL', {birthday: PersonProfilePage.formattedBirthday(person.birthday)});
			refresh();
		}


		override protected function refresh():void {
			nameTF.width = _width - 10;
			birthdayTF.y = nameTF.y + nameTF.textHeight + 10;
		}

		override public function get calculatedHeight():int {
			return birthdayTF.y + birthdayTF.textHeight + 10;
		}
	}
}
