package tree.view.gui.profile {
import com.somewater.display.Photo;
import com.somewater.storage.I18n;
import com.somewater.text.LinkLabel;

import flash.display.Shape;
import flash.events.Event;

import tree.common.Config;
import tree.model.JoinType;
import tree.model.Person;
import tree.view.gui.Button;
import tree.view.gui.PageBase;
import tree.view.gui.StandartButton;
import tree.view.gui.UIComponent;

public class EditPersonProfilePage extends PageBase{

		public static const NAME:String = 'EditPersonProfilePage';

		internal var photo:Photo;
		internal var photoMask:Shape;
		internal var editProfileButton:Button;
		internal var profileLink:com.somewater.text.LinkLabel;
		internal var familyTreeLink:com.somewater.text.LinkLabel;
		internal var editPhotoLink:com.somewater.text.LinkLabel;
		internal var deletePhotoLink:com.somewater.text.LinkLabel;

		internal var readonlyInfo:ReadonlyInfo;
		internal var editableInfo:EditableInfo;
		internal var familyBlock:FamilyBlock;
		internal var saveButtonBlock:SaveButtonBlock;
		internal var editable:Boolean;

		public function EditPersonProfilePage() {
			photo = new Photo(Photo.SIZE_MAX | Photo.ORIENTED_CENTER, 90, 90);
			photoMask = new Shape();
			photoMask.graphics.beginFill(0);
			photoMask.graphics.drawRoundRectComplex(0,0,90,90,5,5,5,5);
			photo.mask = photoMask
			addChild(photo);
			addChild(photoMask);

			editProfileButton = new StandartButton();
			editProfileButton.textField.multiline = true;
			editProfileButton.label = I18n.t('EDIT_DATA');
			addChild(editProfileButton);

			familyTreeLink = new com.somewater.text.LinkLabel(null, 0x2881C6, 11, true);
			familyTreeLink.text = I18n.t('FAMILY_TREE');
			addChild(familyTreeLink);

			editPhotoLink = new com.somewater.text.LinkLabel(null, 0x2881C6, 11, true);
			editPhotoLink.text = I18n.t('EDIT_PHOTO');
			addChild(editPhotoLink);

			deletePhotoLink = new com.somewater.text.LinkLabel(null, 0xc72928, 11, true);
			deletePhotoLink.text = I18n.t('DELETE_PHOTO');
			addChild(deletePhotoLink);

			profileLink = new com.somewater.text.LinkLabel(null, 0x2881C6, 11, true);
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
			return NAME;
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

			photoMask.x = photo.x = contentX;
			photoMask.y = photo.y = contentY;

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
										   joinType:JoinType = null, from:Person = null):void{
			if(!person) return;
			this.visible = true;
			this.editable = editable;
			photo.source = person.photo;
			if(!photo.source) setDefaultPhoto(person.male);
			if(editable){
				editableInfo.setPerson(person, joinType, from);
			}else{
				readonlyInfo.setPerson(person);
			}

			readonlyInfo.visible = !editable;
			editableInfo.visible = editable;
			editPhotoLink.visible = editable;
			deletePhotoLink.visible = editable && person.photo;
			editProfileButton.visible = !editable && !person.isNew;

			familyBlock.setPerson(person, editable);
			saveButtonBlock.editable = editable;

			refresh();
		}

		public function setDefaultPhoto(male:Boolean):void {
			photo.source = Config.loader.createMc('assets.DefaultPhoto_' + (male ? 'male' : 'female'));
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
