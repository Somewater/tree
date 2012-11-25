package tree.view.gui.profile {
import com.somewater.storage.I18n;
import com.somewater.text.LinkLabel;

import fl.core.UIComponent;

import flash.events.Event;

import flash.net.URLRequest;
import flash.net.navigateToURL;

import tree.command.GotoLinkCommand;

import tree.common.IClear;
import tree.model.JoinType;
import tree.model.Person;
import tree.signal.ModelSignal;
import tree.signal.ViewSignal;
import tree.view.gui.GuiControllerBase;
import tree.view.gui.notes.PersonNotesPage;
import tree.view.window.MessageWindow;

public class EditProfileController extends GuiControllerBase implements IClear{

		private var page:EditPersonProfilePage;

		private var person:Person;
		private var from:Person;
		private var joinType:JoinType;

		public function EditProfileController(page:EditPersonProfilePage) {
			this.page = page;
			super(page);

			page.editableInfo.sexChange.add(onSexChanged);

			// edit/read switch mode
			page.cancelEditLink.link.add(onCancelEditProfile);
			page.saveProfileButton.click.add(onSaveEditedData);
			page.comboBox.personChanged.add(onPersonChanged);
			page.extEditLink.link.add(onExtEditionClicked);		}

		private function onCreateNewProfile(...args):void {
			bus.dispatch(ViewSignal.START_EDIT_PERSON, null, null, null);
		}

		override public function clear():void{
			page = null;
			super.clear();
			model.editing.editEnabled = false;
		}

		override public function start(...args):void {
			super.start(args);
			gui.switcher.profile = true;
			person = args[0];
			if(!person){
				page.visible = false;
				return;
			}
			page.visible = true;
			joinType = args[1];
			from = args[2];

			model.editing.editEnabled = true;
			page.onPersonSelected(person, joinType, from);
		}

		private function onCancelEditProfile(...args):void {
			goBack();
		}

		private function onSaveEditedData(...args):void {
			if(model.constructionInProcess){
				new MessageWindow(I18n.t('CANT_SAVE_PERSON')).open();
				return;
			}
			var selected:Person = page.getSelectedFromCombo();
			if(selected){
				bus.dispatch(ModelSignal.EDIT_PROFILE, selected, model.editing.joinType, model.editing.from);
			}else{
				page.editableInfo.updatePersonProperties(model.editing.edited)
				bus.dispatch(ModelSignal.EDIT_PROFILE, model.editing.edited, model.editing.joinType, model.editing.from);
			}
			goBack();
		}

		private function onSexChanged(male:Boolean):void{
			model.editing.edited.male = male;
			page.editableInfo.setSex(male, model.editing.joinType, model.editing.from);
		}

		/**
		 * Предпринять действие после того, как редактирование персоны закончено (отменено или успешно сохранено)
		 */
		private function goBack():void{
			var edited:Person = model.editing.edited;
			var joinType:JoinType = model.editing.joinType;
			var from:Person = model.editing.from;
			model.editing.clear();

			model.editing.editEnabled = false;
			if(edited.isNew && model.editing.from)
				edited = model.editing.from;

			if(model.selectedPerson == null || (edited.isNew && model.selectedPerson == edited)){
				model.selectedPerson = model.owner;
			}

			gui.setPage(PersonProfilePage.NAME)
		}

		private function onPersonChanged(item:DPItem = null):void{
			page.editableInfo.enabled = item == null || item.newPerson;
		}

		private function onExtEditionClicked(l:LinkLabel):void{
			new GotoLinkCommand(GotoLinkCommand.GOTO_EDIT_PROFILE, model.editing.edited).execute();
		}
	}
}
