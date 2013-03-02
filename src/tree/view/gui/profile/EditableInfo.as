package tree.view.gui.profile {
import com.gskinner.motion.GTween;
import com.somewater.storage.I18n;
	import com.somewater.text.EmbededTextField;

	import fl.controls.CheckBox;
import fl.controls.TextInput;

import flash.display.DisplayObject;
import flash.events.Event;

import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;

import tree.common.Config;

import tree.model.Join;
	import tree.model.JoinType;

	import tree.model.Person;
import tree.view.Tweener;
import tree.view.gui.DateSelector;
import tree.view.gui.TreeComboBox;
import tree.view.gui.TreeTextInput;
import tree.view.gui.UIComponent;

	public class EditableInfo extends UIComponent{

		private var firstNameLabel:EmbededTextField;
		private var firstNameInput:TreeTextInput;

	    private var lastNameLabel:EmbededTextField;
		private var lastNameInput:TreeTextInput;

		private var middleNameLabel:EmbededTextField;
		private var middleNameInput:TreeTextInput;

		private var maidenNameLabel:EmbededTextField;
		private var maidenNameInput:TreeTextInput;
		private var maidenVisible:Boolean = true;

		private var birthdayLabel:EmbededTextField;
		private var birthdayInput:DateSelector;

		private var died:CheckBox;
		private var diedY:int;
		private var deathVisible:Boolean = true;

		private var deathDayLabel:EmbededTextField;
		private var deathDayInput:DateSelector;
		private var deathDayInputY:int;

		private var sexSelectorLabel:EmbededTextField;
		private var sexSelector:SexSelector;
		private var sexSelectorVisible:Boolean = true;

		public var sexChange:ISignal;

		private var initedTick:uint;

		public function EditableInfo() {
			firstNameLabel = new EmbededTextField(null, 0x000000, 12, true);
			firstNameLabel.text = I18n.t('FIRST_NAME');
			addChild(firstNameLabel);

			firstNameInput = new TreeTextInput();
			firstNameInput.height = 28;

			lastNameLabel = new EmbededTextField(null, 0x000000, 12, true);
			lastNameLabel.text = I18n.t('LAST_NAME')
			addChild(lastNameLabel);

			lastNameInput = new TreeTextInput();
			lastNameInput.height = 28;

			middleNameLabel = new EmbededTextField(null, 0x000000, 12, true);
			middleNameLabel.text = I18n.t('MIDDLE_NAME');
			addChild(middleNameLabel);

			middleNameInput = new TreeTextInput();
			middleNameInput.height = 28;

			maidenNameLabel = new EmbededTextField(null, 0x000000, 12, true);
			maidenNameLabel.text = I18n.t('MAIDEN_NAME');
			addChild(maidenNameLabel);

			maidenNameInput = new TreeTextInput();
			maidenNameInput.height = 28;

			addChild(lastNameInput);
			addChild(maidenNameInput);
			addChild(firstNameInput)
			addChild(middleNameInput);

			birthdayLabel = new EmbededTextField(null, 0x000000, 12, true);
			birthdayLabel.text = I18n.t('MALE_DEAD_QUESTION');
			addChild(birthdayLabel);

			birthdayInput = new DateSelector();
			birthdayInput.height = 28;
			addChild(birthdayInput);

			died = new CheckBox();
			died.addEventListener(Event.CHANGE, onDiedChanged)
			died.label = I18n.t('MALE_DEAD_QUESTION');
			died.tabEnabled = false;
			addChild(died);

			deathDayLabel = new EmbededTextField(null, 0x000000, 12, true);
			deathDayLabel.text = I18n.t('MALE_DEAD_QUESTION');
			addChild(deathDayLabel);

			deathDayInput = new DateSelector();
			deathDayInput.height = 28;
			addChild(deathDayInput);

			sexSelectorLabel = new EmbededTextField(null, 0x000000, 12, true);
			sexSelectorLabel.text = I18n.t('SEX');
			addChild(sexSelectorLabel)

			sexSelector = new SexSelector();
			sexSelector.change.add(onSexChanged);
			addChild(sexSelector);

			sexChange = new Signal(Boolean);

			initedTick = Config.ticker.getTimer;

			refresh();
		}

		override public function clear():void {
			super.clear();
			sexChange.removeAll();
			sexSelector.clear();
			died.removeEventListener(Event.CHANGE, onDiedChanged)
			birthdayInput.clear();
			deathDayInput.clear();
		}

		public function setPerson(person:Person, joinType:JoinType = null, from:Person = null):void {
			firstNameInput.text = person.firstName;
			lastNameInput.text = person.lastName;
			middleNameInput.text = person.middleName;
			birthdayInput.date = person.birthday;
			deathDayInput.date = person.deathday;
			died.selected = person.died;
			sexSelector.male = person.male;

			sexSelectorVisible = person.isNew && !joinType;
			setVisibility(sexSelector, sexSelectorVisible);
			setVisibility(sexSelectorLabel, sexSelectorVisible);

			onDiedChanged(null);

			setSex(person.male, joinType, from);
		}

		public function updatePersonProperties(person:Person):void{
			person.firstName = firstNameInput.text;
			person.lastName = lastNameInput.text;
			person.middleName = middleNameInput.text;
			person.maidenName = maidenNameInput.text;
			person.died = died.selected;
			person.male = sexSelector.male;
			person.birthday = birthdayInput.date;
			person.deathday = died.selected ? deathDayInput.date : null;
		}

		override protected function refresh():void {
			var controls:Array = [
				(sexSelectorVisible ? [sexSelectorLabel, sexSelector] : null),
				lastNameLabel,
				lastNameInput,
				(maidenVisible? 4 : null),
				(maidenVisible? maidenNameLabel : null),
				(maidenVisible? maidenNameInput : null),
				4,
				firstNameLabel,
				firstNameInput,
				4,
				middleNameLabel, 
				middleNameInput,
				4,
				birthdayLabel, 
				birthdayInput,
				4,
				died,
				(deathVisible ? 4 : null),
				(deathVisible ? deathDayLabel : null),
				(deathVisible ? deathDayInput : null)
			];

			var nextY:int = 0;
			var nextX:int = 0;
			for each(var line:* in controls){
				if(!line)
					continue;
				if(line is Number){
					nextY += Number(line);
					continue;
				}
				if(!(line is Array))
					line = [line];
				nextX = 0;
				var maxControlHeight:int = 0;
				for each(var control:DisplayObject in line){
					if(control){
						control.x = nextX;
						if(control == died) diedY = nextY;
						if(control == deathDayInput) deathDayInputY = nextY;
						setYPos(control, nextY);
						control.width = line.length > 1 ? (nextX == 0 ? 70 : _width - nextX)  : _width;
						maxControlHeight = Math.max(maxControlHeight, control.height);
					}
					nextX += 70;
				}
				nextY += maxControlHeight + 6;
			}

			dispatchEvent(new Event(Event.RESIZE))
		}

		override public function get calculatedHeight():int {
			return died.selected ? deathDayInputY + deathDayInput.height : diedY + died.height;
		}

		private function onSexChanged(...args):void{
			sexChange.dispatch(sexSelector.male);
		}

		public function setSex(male:Boolean, joinType:JoinType = null, fromPerson:Person = null):void{
			birthdayLabel.text = I18n.t(male ? 'MALE_BORN_FROM' : 'FEMALE_BORN_FROM');
			died.label = I18n.t(male ? 'MALE_DEAD_QUESTION' : 'FEMALE_DEAD_QUESTION');
			deathDayLabel.text = I18n.t(male ? 'MALE_DEAD' : 'FEMALE_DEAD');
			sexSelector.male = male;

			maidenVisible = !male;
			setVisibility(maidenNameInput, maidenVisible);
			setVisibility(maidenNameLabel, maidenVisible);

			refresh();
		}

		private function setVisibility(c:DisplayObject, visible:Boolean):void{
			if(initedTick != Config.ticker.getTimer){
				c.visible = true;
				Tweener.to(c, 0.2, {alpha: visible ? 1 : 0}, {onComplete: function(g:GTween):void{
					c.visible = c.alpha == 0? false : true;
				}})
			}else{
				c.visible = visible;
			}
		}

		private function setYPos(c:DisplayObject, posY:int):void{
			if(initedTick != Config.ticker.getTimer)
				Tweener.to(c, 0.2, {y: posY}, {delay: 0.2});
			else
				c.y = posY;
		}

		private function onDiedChanged(event:Event):void{
			deathVisible = died.selected;
			setVisibility(deathDayInput, deathVisible);
			setVisibility(deathDayLabel, deathVisible);

			if(event)
				refresh();
		}

		public function set enabled(enabled:Boolean):void {
			firstNameInput.enabled = enabled;
			lastNameInput.enabled = enabled;
			middleNameInput.enabled = enabled;
			maidenNameInput.enabled = enabled;
			died.enabled = enabled;
			sexSelector.enabled = enabled;
			birthdayInput.enabled = enabled;
			died.enabled = enabled;
			deathDayInput.enabled = enabled;
		}
	}
}