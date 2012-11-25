package tree.view.gui.profile {
import com.somewater.display.Photo;
import com.somewater.storage.I18n;
import com.somewater.text.LinkLabel;

import fl.controls.ComboBox;

import flash.display.DisplayObject;

import flash.display.Shape;
import flash.events.Event;

import tree.common.Config;
import tree.model.JoinType;
import tree.model.Person;
import tree.view.Tweener;
import tree.view.gui.Button;
import tree.view.gui.PageBase;
import tree.view.gui.StandartButton;
import tree.view.gui.TreeComboBox;
import tree.view.gui.UIComponent;

public class EditPersonProfilePage extends PageBase{

		public static const NAME:String = 'EditPersonProfilePage';

	    internal var comboBox:PersonComboBox;

		internal var editableInfo:EditableInfo;
		internal var saveProfileButton:Button;
		private var saveProfileButtonGround:Shape;
		internal var cancelEditLink:com.somewater.text.LinkLabel;
		internal var extEditLink:com.somewater.text.LinkLabel;

		public function EditPersonProfilePage() {
			comboBox = new PersonComboBox();
			addChild(comboBox);

			editableInfo = new EditableInfo();
			editableInfo.addEventListener(Event.RESIZE, onEditableInfoResized)
			addChild(editableInfo);

			saveProfileButtonGround = new Shape();
			addChild(saveProfileButtonGround);

			saveProfileButton = new StandartButton();
			saveProfileButton.textField.size += 2;
			saveProfileButton.label = I18n.t('SAVE_PROFILE');
			addChild(saveProfileButton);

			cancelEditLink = new com.somewater.text.LinkLabel(null, 0x2881C6, 11, true);
			cancelEditLink.text = I18n.t('CANCEL_EDIT');
			addChild(cancelEditLink);

			extEditLink = new com.somewater.text.LinkLabel(null, 0x2881C6, 11, true);
			extEditLink.text = I18n.t('EXTENDED_EDIT');
			addChild(extEditLink);
		}

		override public function get pageName():String {
			return NAME;
		}

		override public function clear():void {
			super.clear();
			editableInfo.clear();
			saveProfileButton.clear();
			cancelEditLink.clear();
			extEditLink.clear();
			editableInfo.removeEventListener(Event.RESIZE, onEditableInfoResized)
			comboBox.clear();
		}

		override protected function refresh():void {
			super.refresh();

			var contentX:int = 20;
			var contentY:int = 20;
			var contentWidth:int = _width - contentX - 20;
			var contentHeight:int = _height - contentY - 20;;

			if(comboBox.visible){
				comboBox.x = contentX
				comboBox.y = contentY;
				comboBox.setSize(contentWidth, 105)
				contentY += comboBox.height + 15;
			}

			editableInfo.x = contentX;
			editableInfo.y = contentY;
			editableInfo.width = contentWidth;

			refreshSaveButtonPos();
		}

		internal function onPersonSelected(person:Person, joinType:JoinType = null, from:Person = null):void{
			if(!person) return;
			this.visible = true;
			if(joinType != null && from != null) {
				comboBox.visible = true;
				comboBox.setPerson(person, joinType, from);
			} else
				comboBox.visible = false;

			editableInfo.setPerson(person, joinType, from);
			refresh();
		}

		private function onEditableInfoResized(event:Event):void{
			refreshSaveButtonPos(true);
		}

		private function refreshSaveButtonPos(anim:Boolean = false):void{
			const PADDING:int = 10;

			saveProfileButton.x = PADDING * 2;
			var saveButtonY:int = editableInfo.y + editableInfo.calculatedHeight + PADDING * 2
			setYPos(saveProfileButton, saveButtonY, anim);
			saveProfileButton.setSize(_width - PADDING * 4, 27);

			saveProfileButtonGround.graphics.clear();
			saveProfileButtonGround.graphics.beginFill(0xFFFFFF);
			saveProfileButtonGround.x = saveProfileButton.x;
			setYPos(saveProfileButtonGround, saveButtonY, anim);
			saveProfileButtonGround.y = saveProfileButton.y;
			saveProfileButtonGround.graphics.drawRoundRectComplex(-PADDING * .5, -PADDING * .5, saveProfileButton.width + PADDING, saveProfileButton.height + PADDING, 5,5,5,5);

			cancelEditLink.x = (width - cancelEditLink.width)* 0.5;
			var canselLinkY:int = saveButtonY + saveProfileButton.height + 10;
			setYPos(cancelEditLink, canselLinkY, anim)

			extEditLink.x = (width - extEditLink.width) * 0.5;
			setYPos(extEditLink, canselLinkY + cancelEditLink.textField.height + 10, anim);
		}

		private function setYPos(c:DisplayObject, posY:int, animated:Boolean):void{
			if(animated)
				Tweener.to(c, 0.2, {y: posY});
			else
				c.y = posY;
		}

		public function getSelectedFromCombo():Person {
			if(comboBox.visible){
				return comboBox.selectedItem && !comboBox.selectedItem.newPerson ? comboBox.selectedItem.person : null;
			}else
				return null;
		}
}
}
