package tree.view.gui.profile {
	import tree.command.Actor;
	import tree.common.IClear;
	import tree.signal.ModelSignal;
	import tree.signal.ViewSignal;

	public class ProfileController extends Actor implements IClear{

		private var page:PersonProfilePage;

		public function ProfileController(page:PersonProfilePage) {
			this.page = page;

			// edit/read switch mode
			page.editProfileButton.click.add(onEditProfile);
			page.saveButtonBlock.cancelEditLink.link.add(onCancelEditProfile);
			page.saveButtonBlock.saveProfileButton.click.add(onSaveEditedData);

			bus.addNamed(ViewSignal.PERSON_SELECTED, page.onPersonSelected);
			page.onPersonSelected(model.selectedPerson);
		}

		public function clear():void{
			page = null;
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
	}
}
