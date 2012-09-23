package tree.view.gui.profile {
	import com.somewater.display.Photo;
	import com.somewater.storage.I18n;
	import com.somewater.storage.I18n;
	import com.somewater.text.EmbededTextField;
	import com.somewater.text.LinkLabel;

	import flash.display.DisplayObject;

	import flash.events.Event;

	import tree.common.Config;

	import tree.model.Person;

	import tree.signal.ViewSignal;

	import tree.view.gui.Button;

	import tree.view.gui.PageBase;
	import tree.view.gui.StandartButton;
	import tree.view.gui.UIComponent;

	public class PersonProfilePage extends PageBase{

		internal var photo:Photo;
		internal var editProfileButton:Button;
		internal var profileLink:LinkLabel;
		internal var familyTreeLink:LinkLabel;
		internal var editPhotoLink:LinkLabel;
		internal var deletePhotoLink:LinkLabel;

		internal var readonlyInfo:ReadonlyInfo;
		internal var editableInfo:EditableInfo;
		internal var familyBlock:FamilyBlock;
		internal var saveButtonBlock:SaveButtonBlock;
		internal var editable:Boolean;

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

			editPhotoLink = new LinkLabel(null, 0x2881C6, 11, true);
			editPhotoLink.text = I18n.t('EDIT_PHOTO');
			addChild(editPhotoLink);

			deletePhotoLink = new LinkLabel(null, 0xc72928, 11, true);
			deletePhotoLink.text = I18n.t('DELETE_PHOTO');
			addChild(deletePhotoLink);

			profileLink = new LinkLabel(null, 0x2881C6, 11, true);
			profileLink.text = I18n.t('PROFILE');
			addChild(profileLink);

			readonlyInfo = new ReadonlyInfo();
			addChild(readonlyInfo);

			editableInfo = new EditableInfo();
			addChild(editableInfo);

			familyBlock = new FamilyBlock();
			addChild(familyBlock);
			familyBlock.addEventListener(Event.RESIZE, onFamilyBlockResized);

			saveButtonBlock = new SaveButtonBlock();
			addChild(saveButtonBlock);
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
			saveButtonBlock.clear();
			readonlyInfo.clear();
			editableInfo.clear();
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

			editPhotoLink.x = editProfileButton.x;
			editPhotoLink.y = editProfileButton.y;

			deletePhotoLink.x = editPhotoLink.x;
			deletePhotoLink.y = editPhotoLink.y + editPhotoLink.height;

			profileLink.x = familyTreeLink.x = editProfileButton.x;

			familyTreeLink.y = photo.y + photo.height - familyTreeLink.textField.textHeight;
			profileLink.y = familyTreeLink.y - familyTreeLink.textField.textHeight - profileLink.textField.textHeight;

			var info:UIComponent = readonlyInfo.visible ? readonlyInfo : editableInfo;
			info.x = contentX;
			info.y = photo.y + photo.height + 15;
			info.width = contentWidth;

			log("INFO HEIGHT: " + info.height);

			familyBlock.x = contentX;
			familyBlock.y = info.y + info.calculatedHeight + 10;
			familyBlock.width = contentWidth;
			familyBlock.maxHeight = _height - familyBlock.y - saveButtonBlock.calculatedHeight - 20;

			saveButtonBlock.x = contentX;
			saveButtonBlock.y = familyBlock.y + familyBlock.calculatedHeight + 10;
			saveButtonBlock.width = contentWidth;
		}

		internal function onPersonSelected(person:Person, editable:Boolean = false,
										   joinSuperType:String = null, from:Person = null):void{
			if(!person) return;
			this.editable = editable;
			photo.source = person.photo;
			if(!photo.source) setDefaultPhoto();
			if(editable){
				editableInfo.setPerson(person, joinSuperType, from);
			}else{
				readonlyInfo.setPerson(person);
			}

			readonlyInfo.visible = !editable;
			editableInfo.visible = editable;
			editPhotoLink.visible = editable;
			deletePhotoLink.visible = editable && person.photo && person.visible;
			editProfileButton.visible = !editable && person.visible;

			familyBlock.setPerson(person, editable);
			saveButtonBlock.editable = editable;

			refresh();
		}

		public function setDefaultPhoto():void {
			photo.source = Config.loader.createMc('assets.DefaultPhoto_male');
		}

		private function onFamilyBlockResized(event:Event):void{
			refresh();
		}

		internal static function formattedBirthday(date:Date):String{
			if(!date) return '    ---';
			return date.date + ' ' + I18n.t('MONTH_GENETIVE_' + date.month) + ' ' + date.fullYear;
		}
	}
}
