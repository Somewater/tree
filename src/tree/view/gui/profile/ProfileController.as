package tree.view.gui.profile {
	import flash.net.URLRequest;
	import flash.net.navigateToURL;

	import tree.command.Actor;
	import tree.common.IClear;
	import tree.model.JoinType;
	import tree.model.Person;
	import tree.model.TreeModel;
	import tree.signal.ModelSignal;
	import tree.signal.ViewSignal;
	import tree.view.gui.GuiControllerBase;
	import tree.view.gui.notes.PersonNotesPage;
	import tree.view.window.MessageWindow;

	public class ProfileController extends GuiControllerBase implements IClear{

		private var page:PersonProfilePage;

		public function ProfileController(page:PersonProfilePage) {
			this.page = page;
			super(page);

			page.profileLink.link.add(onProfileClick);
			page.familyTreeLink.link.add(onFamilyTreeClick)
			page.editPhotoLink.link.add(onEditPhotoClick)
			page.deletePhotoLink.link.add(onDeletePhotoClick);
			page.editableInfo.sexChange.add(onSexChanged);
			page.familyBlock.itemClick.add(onFamalyBlockItemClicked);

			// edit/read switch mode
			page.editProfileButton.click.add(onEditProfile);
			page.saveButtonBlock.cancelEditLink.link.add(onCancelEditProfile);
			page.saveButtonBlock.saveProfileButton.click.add(onSaveEditedData);
			page.saveButtonBlock.createProfileButton.click.add(onCreateNewProfile);

			bus.addNamed(ViewSignal.PERSON_SELECTED, onPersonSelected);
		}

		private function onCreateNewProfile(...args):void {
			bus.dispatch(ViewSignal.START_EDIT_PERSON, null, null, null);
		}

		private function onDeletePhotoClick(...args):void {
			page.setDefaultPhoto(model.editing.edited.male);
			new MessageWindow('TODO: послать запрос на удаление фото').open();
		}

		private function onEditPhotoClick(...args):void {
			new MessageWindow('TODO: выбрать новый файл фотографии').open();
		}

		private function onProfileClick(...args):void {
			navigateToURL(new URLRequest(model.selectedPerson.profileUrl))
		}

		private function onFamilyTreeClick(...args):void{
			new MessageWindow('TODO: открыть дерево относительно человека').open()
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
			var person:Person = args[0] || model.selectedPerson;
			if(!person){
				page.visible = false;
				return;
			}
			page.visible = true;
			var joinType:JoinType = args[1];
			var from:Person = args[2];
			if(args.length > 1 || person.isNew || joinType){
				// редактирование
				model.editing.editEnabled = true;
				page.onPersonSelected(person, true, joinType, from);
			}else{
				// промотр профиля
				model.editing.editEnabled = false;
				page.onPersonSelected(person);
			}
		}

		private function onEditProfile(...args):void {
			bus.dispatch(ViewSignal.START_EDIT_PERSON, model.selectedPerson)
		}

		private function onCancelEditProfile(...args):void {
			goBack();
		}

		private function onSaveEditedData(...args):void {
			bus.dispatch(ModelSignal.EDIT_PROFILE, model.selectedPerson);
			goBack();
		}

		private function onPersonSelected(person:Person):void{
			page.onPersonSelected(person);
		}

		private function onSexChanged(male:Boolean):void{
			model.editing.edited.male = male;
			page.editableInfo.setSex(male, model.editing.joinType, model.editing.from);
			if(!model.editing.edited.photo)
				page.setDefaultPhoto(model.editing.edited.male);
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
				gui.setPage(PersonProfilePage.NAME);
			}else
				page.onPersonSelected(model.selectedPerson);
		}

		private function onFamalyBlockItemClicked(person:Person):void{
			model.editing.editEnabled = false;
			bus.dispatch(ViewSignal.PERSON_SELECTED, person);
			bus.dispatch(ViewSignal.PERSON_CENTERED, person);
		}
	}
}
