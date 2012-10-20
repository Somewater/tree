package tree.view.gui.profile {
	import com.somewater.storage.I18n;
	import com.somewater.text.EmbededTextField;

	import fl.controls.CheckBox;

	import fl.controls.TextInput;
	import fl.data.DataProvider;

	import flash.display.DisplayObject;
	import flash.events.Event;

	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;

	import tree.model.Join;
	import tree.model.JoinType;

	import tree.model.Person;
	import tree.view.gui.TreeComboBox;
	import tree.view.gui.UIComponent;

	public class EditableInfo extends UIComponent{

		private var joinTypeSelector:TreeComboBox;
		private var joinTypeLabel:EmbededTextField;

		private var firstNameLabel:EmbededTextField;
		private var firstNameInput:TextInput;

	    private var lastNameLabel:EmbededTextField;
		private var lastNameInput:TextInput;

		private var middleNameLabel:EmbededTextField;
		private var middleNameInput:TextInput;

		private var birthdayLabel:EmbededTextField;
		private var birthdayInput:TextInput;

		private var died:CheckBox;

		private var sexSelectorLabel:EmbededTextField;
		private var sexSelector:SexSelector;

		public var sexChange:ISignal;

		public function EditableInfo() {
			joinTypeSelector = new TreeComboBox();
			//addChild(joinTypeSelector);

			joinTypeLabel = new EmbededTextField(null, 0x5B5B5B, 13);
			addChild(joinTypeLabel);

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
			birthdayLabel.text = I18n.t('MALE_DEAD_QUESTION');
			addChild(birthdayLabel);

			birthdayInput = new TextInput();
			addChild(birthdayInput);

			died = new CheckBox();
			died.label = I18n.t('MALE_DEAD_QUESTION');
			addChild(died);

			sexSelectorLabel = new EmbededTextField(null, 0x525252, 13);
			sexSelectorLabel.text = I18n.t('SEX');
			addChild(sexSelectorLabel)

			sexSelector = new SexSelector();
			sexSelector.change.add(onSexChanged);
			addChild(sexSelector);

			sexChange = new Signal(Boolean);
		}

		override public function clear():void {
			super.clear();
			sexChange.removeAll();
			sexSelector.clear();
		}

		public function setPerson(person:Person, joinType:JoinType = null, from:Person = null):void {
			firstNameInput.text = person.firstName;
			lastNameInput.text = person.lastName;
			middleNameInput.text = person.middleName;
			birthdayInput.text = PersonProfilePage.formattedBirthday(person.birthday);
			died.selected = person.died;
			joinTypeSelector.removeAll();
			//joinTypeSelector.dataProvider = new DataProvider(['родственная связь 1','родственная связь 2','родственная связь 3'])

			if(joinType){
				joinTypeLabel.visible = true;
			}else
				joinTypeLabel.visible = false;

			sexSelector.male = person.male;
			setSex(person.male, joinType, from);
			sexSelector.visible = sexSelectorLabel.visible = person.isNew && !joinType;

			refresh();
		}

		public function updatePersonProperties(person:Person):void{
			person.firstName = firstNameInput.text;
			person.lastName = lastNameInput.text;
			person.middleName = middleNameInput.text;
			person.died = died.selected;
			person.male = sexSelector.male;
		}

		override protected function refresh():void {
			super.refresh();

			var controls:Array = [
				(joinTypeLabel.visible ? [joinTypeLabel] : null),
				[firstNameLabel, firstNameInput],
				[lastNameLabel, lastNameInput],
				[middleNameLabel, middleNameInput],
				[birthdayLabel, birthdayInput],
				(sexSelector.visible ? [sexSelectorLabel, sexSelector] : null),
				[null, died]
			];

			var nextY:int = 0;
			var nextX:int = 0;
			for each(var line:* in controls){
				if(!line)
					continue;
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

		override public function get calculatedHeight():int {
			return died.y + died.height;
		}

		private function onSexChanged(...args):void{
			sexChange.dispatch(sexSelector.male);
		}

		public function setSex(male:Boolean, joinType:JoinType = null, fromPerson:Person = null):void{
			if(joinType){
				joinTypeLabel.text = I18n.t('RELATIVE_BY',
						{relative : Join.joinBy(joinType.superType, male).toLocaleString(), name: fromPerson.fullname});
			}
			birthdayLabel.text = I18n.t(male ? 'MALE_BORN_FROM' : 'FEMALE_BORN_FROM');
			died.label = I18n.t(male ? 'MALE_DEAD_QUESTION' : 'FEMALE_DEAD_QUESTION');
			sexSelector.male = male;
		}
	}
}
