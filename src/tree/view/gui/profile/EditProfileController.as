package tree.view.gui.profile {
import com.somewater.storage.I18n;

import flash.net.URLRequest;
import flash.net.navigateToURL;

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

			bus.addNamed(ViewSignal.PERSON_SELECTED, onPersonSelected);
		}

		private function onCreateNewProfile(...args):void {
			bus.dispatch(ViewSignal.START_EDIT_PERSON, null, null, null);
		}

		override public function clear():void{
			page = null;
			super.clear();
			bus.removeNamed(ViewSignal.PERSON_SELECTED, onPersonSelected);
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
			page.editableInfo.updatePersonProperties(model.editing.edited)
			bus.dispatch(ModelSignal.EDIT_PROFILE, model.editing.edited, model.editing.joinType, model.editing.from);
			goBack();
		}

		private function onPersonSelected(person:Person):void{
			page.onPersonSelected(person, joinType, from);
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

			model.editing.editEnabled = false;

			if(edited.isNew){
				if(model.selectedPerson == edited)
					model.selectedPerson = null;
				gui.setPage(PersonNotesPage.NAME);
			}else
				gui.setPage(PersonProfilePage.NAME)
		}
	}
}
