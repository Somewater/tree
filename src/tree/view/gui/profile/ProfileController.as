package tree.view.gui.profile {
	import com.somewater.storage.I18n;

	import flash.net.URLRequest;
	import flash.net.navigateToURL;

	import tree.command.Actor;
import tree.command.RemovePerson;
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

			page.viewProfile.click.add(onProfileClick);
			page.viewTree.click.add(onFamilyTreeClick)
			page.addPhoto.click.add(onEditPhotoClick);
			page.sendMessage.click.add(onSendMessageClick);
			page.deleteProfile.click.add(onDeleteProfileClick);
			page.invite.click.add(onInviteClick);


			// edit/read switch mode
			page.editProfile.click.add(onEditProfile);

			bus.addNamed(ViewSignal.PERSON_SELECTED, onPersonSelected);
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

		private function onSendMessageClick(...args):void{
			new MessageWindow('TODO: открыть страницу отсылки сообщения').open()
		}

		private function onDeleteProfileClick(...args):void{
			new RemovePerson(model.selectedPerson).execute();
		}

		private function onInviteClick(...args):void{
			new MessageWindow('TODO: пригласить в соц сеть').open()
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
			// промотр профиля
			model.editing.editEnabled = false;
			page.onPersonSelected(person);
		}

		private function onEditProfile(...args):void {
			bus.dispatch(ViewSignal.START_EDIT_PERSON, model.selectedPerson)
		}

		private function onPersonSelected(person:Person):void{
			page.visible = true;
			page.onPersonSelected(person);
		}
	}
}
