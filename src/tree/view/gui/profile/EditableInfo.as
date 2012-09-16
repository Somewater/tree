package tree.view.gui.profile {
	import com.somewater.storage.I18n;
	import com.somewater.text.EmbededTextField;

	import fl.controls.CheckBox;

	import fl.controls.TextInput;
	import fl.data.DataProvider;

	import flash.display.DisplayObject;

	import tree.model.Person;
	import tree.view.gui.TreeComboBox;
	import tree.view.gui.UIComponent;

	public class EditableInfo extends UIComponent{

		private var joinTypeSelector:TreeComboBox;

		private var firstNameLabel:EmbededTextField;
		private var firstNameInput:TextInput;

	    private var lastNameLabel:EmbededTextField;
		private var lastNameInput:TextInput;

		private var middleNameLabel:EmbededTextField;
		private var middleNameInput:TextInput;

		private var birthdayLabel:EmbededTextField;
		private var birthdayInput:TextInput;

		private var died:CheckBox;

		public function EditableInfo() {
			joinTypeSelector = new TreeComboBox();
			addChild(joinTypeSelector);

			firstNameLabel = new EmbededTextField(null, 0x525252, 13);
			firstNameLabel.text = I18n.t('FIRST_NAME');
			addChild(firstNameLabel);

			firstNameInput = new TextInput();
			addChild(firstNameInput)

			lastNameLabel = new EmbededTextField(null, 0x525252, 13);
			lastNameLabel.text = I18n.t('LAST_NAME')
			addChild(lastNameLabel);

			lastNameInput = new TextInput();
			addChild(lastNameInput);

			middleNameLabel = new EmbededTextField(null, 0x525252, 13);
			middleNameLabel.text = I18n.t('MIDDLE_NAME');
			addChild(middleNameLabel);

			middleNameInput = new TextInput();
			addChild(middleNameInput);

			birthdayLabel = new EmbededTextField(null, 0x525252, 13);
			birthdayLabel.text = I18n.t('BORN_FROM');
			addChild(birthdayLabel);

			birthdayInput = new TextInput();
			addChild(birthdayInput);

			died = new CheckBox();
			died.label = I18n.t('DEAD_QUESTION');
			addChild(died);
		}

		override public function clear():void {
			super.clear();
		}

		public function setPerson(person:Person):void {
			firstNameInput.text = person.firstName;
			lastNameInput.text = person.lastName;
			middleNameInput.text = person.middleName;
			birthdayInput.text = PersonProfilePage.formattedBirthday(person.birthday);
			died.selected = person.died;
			joinTypeSelector.removeAll();
			joinTypeSelector.dataProvider = new DataProvider(['родственная связь 1','родственная связь 2','родственная связь 3'])

			refresh();
		}

		override protected function refresh():void {
			super.refresh();

			var controls:Array = [
				[joinTypeSelector],
				[firstNameLabel, firstNameInput],
				[lastNameLabel, lastNameInput],
				[middleNameLabel, middleNameInput],
				[birthdayLabel, birthdayInput],
				[null, died]
			];

			var nextY:int = 0;
			var nextX:int = 0;
			for each(var line:* in controls){
				if(!(line is Array))
					line = [line];
				nextX = 0;
				var maxControlHeight:int = 0;
				for each(var control:DisplayObject in line){
					if(control){
						control.x = nextX;
						control.y = nextY;
						control.width = line.length > 1 ? (nextX == 0 ? 70 : _width - nextX)  : _width;
						maxControlHeight = Math.max(maxControlHeight, control.height);
					}
					nextX += 70;
				}
				nextY += maxControlHeight + 8;
			}
		}
	}
}
