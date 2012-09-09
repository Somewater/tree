package tree.view.gui.profile {
	import com.somewater.display.Photo;
	import com.somewater.storage.I18n;
	import com.somewater.storage.I18n;
	import com.somewater.text.EmbededTextField;
	import com.somewater.text.LinkLabel;

	import flash.events.Event;

	import tree.model.Person;

	import tree.signal.ViewSignal;

	import tree.view.gui.Button;

	import tree.view.gui.PageBase;
	import tree.view.gui.StandartButton;

	public class PersonProfilePage extends PageBase{

		private var photo:Photo;
		private var editProfileButton:Button;
		private var profileLink:LinkLabel;
		private var familyTreeLink:LinkLabel;

		private var nameTF:EmbededTextField;
		private var birthdayTF:EmbededTextField;
		private var familyBlock:FamilyBlock;
		private var createProfileButton:Button;

		public function PersonProfilePage() {
			photo = new Photo(Photo.SIZE_MAX | Photo.ORIENTED_CENTER, 90, 90);
			addChild(photo);

			editProfileButton = new StandartButton();
			editProfileButton.textField.multiline = true;
			editProfileButton.label = I18n.t('EDIT_DATA');
			addChild(editProfileButton);

			familyTreeLink = new LinkLabel(null, 0x2881C6, 11, true);
			familyTreeLink.text = I18n.t('FAMILY_TREE');
			addChild(familyTreeLink);

			profileLink = new LinkLabel(null, 0x2881C6, 11, true);
			profileLink.text = I18n.t('PROFILE');
			addChild(profileLink);

			nameTF = new EmbededTextField(null, 0, 17, true, true);
			addChild(nameTF);

			birthdayTF = new EmbededTextField(null, 0x5B5B5B, 13);
			addChild(birthdayTF);

			familyBlock = new FamilyBlock();
			addChild(familyBlock);
			familyBlock.addEventListener(Event.RESIZE, onFamilyBlockResized);

			createProfileButton = new StandartButton();
			createProfileButton.label = I18n.t('CREATE_NEW_PROFILE');
			addChild(createProfileButton);

			bus.addNamed(ViewSignal.PERSON_SELECTED, onPersonSelected);
			onPersonSelected(model.selectedPerson);
		}

		override public function get pageName():String {
			return 'PersonProfilePage';
		}

		override public function clear():void {
			super.clear();
			photo.clear();
			editProfileButton.clear();
			profileLink.clear();
			familyTreeLink.clear();

			familyBlock.clear();
			familyBlock.removeEventListener(Event.RESIZE, onFamilyBlockResized);
			createProfileButton.clear();
		}

		override protected function refresh():void {
			super.refresh();
			var contentX:int = 20;
			var contentY:int = 0;
			var contentWidth:int = _width - contentX - 20;
			var contentHeight:int = _height - contentY - 20;;

			photo.x = contentX;
			photo.y = contentY;

			editProfileButton.x = photo.x + photo.width + 8;
			editProfileButton.y = photo.y;
			editProfileButton.setSize(contentWidth - editProfileButton.x + contentX, 45);

			profileLink.x = familyTreeLink.x = editProfileButton.x;

			familyTreeLink.y = photo.y + photo.height - familyTreeLink.textField.textHeight;
			profileLink.y = familyTreeLink.y - familyTreeLink.textField.textHeight - profileLink.textField.textHeight;

			nameTF.x = contentX;
			nameTF.y = photo.y + photo.height + 15;
			nameTF.width = contentWidth;

			birthdayTF.x = contentX;
			birthdayTF.y = nameTF.y + nameTF.textHeight + 10;

			familyBlock.x = contentX;
			familyBlock.y = birthdayTF.y + birthdayTF.textHeight + 10;
			familyBlock.width = contentWidth;
			familyBlock.maxHeight = _height - familyBlock.y - 80;

			createProfileButton.x = contentX;
			createProfileButton.y = familyBlock.y + familyBlock.calculatedHeight + 10;
			createProfileButton.setSize(contentWidth, 27);
		}

		private function onPersonSelected(person:Person):void{
			if(!person) return;
			photo.source = person.photo;
			nameTF.text = person.fullname;
			birthdayTF.text = I18n.t('BIRTHDAY_LABEL', {birthday: (person.birthday ? person.birthday.toString() : '    ---')});
			familyBlock.setPerson(person);

			refresh();
		}

		private function onFamilyBlockResized(event:Event):void{
			refresh();
		}
	}
}
