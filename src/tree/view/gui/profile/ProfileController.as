package tree.view.gui.profile {
	import flash.net.URLRequest;
	import flash.net.navigateToURL;

	import tree.command.Actor;
	import tree.common.IClear;
	import tree.model.Person;
	import tree.model.TreeModel;
	import tree.signal.ModelSignal;
	import tree.signal.ViewSignal;
	import tree.view.gui.GuiControllerBase;
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

			// edit/read switch mode
			page.editProfileButton.click.add(onEditProfile);
			page.saveButtonBlock.cancelEditLink.link.add(onCancelEditProfile);
			page.saveButtonBlock.saveProfileButton.click.add(onSaveEditedData);
			page.saveButtonBlock.createProfileButton.click.add(onCreateNewProfile);

			bus.addNamed(ViewSignal.PERSON_SELECTED, onPersonSelected);
		}

		private function onCreateNewProfile(...args):void {
			var newPerson:Person = model.trees.first.persons.allocate(model.trees.first.nodes);
			bus.dispatch(ViewSignal.EDIT_PERSON, newPerson, null, null);
		}

		private function onDeletePhotoClick(...args):void {
			page.setDefaultPhoto();
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
		}

		override public function start(...args):void {
			onPersonSelected(model.selectedPerson);
		}

		private function onEditProfile(...args):void {
			page.onPersonSelected(model.selectedPerson, true);
		}

		private function onCancelEditProfile(...args):void {
			page.onPersonSelected(model.selectedPerson);
		}

		private function onSaveEditedData(...args):void {
			bus.dispatch(ModelSignal.EDIT_PROFILE, model.selectedPerson);
			page.onPersonSelected(model.selectedPerson);
		}

		private function onPersonSelected(person:Person):void{
			page.onPersonSelected(person);
		}
	}
}
