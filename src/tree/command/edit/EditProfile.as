package tree.command.edit {
	import tree.command.Command;
	import tree.common.Config;
	import tree.model.Person;

	public class EditProfile extends Command{

		private var person:Person;

		public function EditProfile(person:Person) {
			this.person = person;
		}

		override public function execute():void {
			message('TODO: послать изменения профайла на сервер')
		}
	}
}
