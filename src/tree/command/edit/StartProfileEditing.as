package tree.command.edit {
	import tree.Tree;
	import tree.command.Command;
	import tree.common.Config;
	import tree.model.Join;
	import tree.model.JoinType;
	import tree.model.Person;
	import tree.view.gui.Gui;
import tree.view.gui.profile.EditPersonProfilePage;
import tree.view.gui.profile.PersonProfilePage;

	/**
	 * Открыть интерфейс редактирования персоны (старой либо ново созданной)
	 */
	public class StartProfileEditing extends Command{

		private var person:Person;
		private var joinType:JoinType;
		private var from:Person

		public function StartProfileEditing(person:Person = null, joinType:JoinType = null, from:Person = null) {
			this.person = person;
			this.joinType = joinType;
			this.from = from;
		}

		override public function execute():void {
			if(!person){
				//person = model.trees.first.persons.allocate(model.trees.first.nodes);
				person = new Person(from ? from.tree : null);
				person.uid = Tree.instance.getTmpPersonUid()
				person.tree = from ? from.tree : null;
				// настроить
				if(joinType){
					person.male = joinType.manAssoc;
					var join:Join = new Join(null);
					join.type = from.male ? joinType.associatedTypeForMale : joinType.associatedTypeForFemale;
					join.associate = from;
					join.from = person;
					//person.add(join)
				}
			}

			model.selectedPerson = person;
			model.editing.edited = person;
			model.editing.joinType = joinType;
			model.editing.from = from;
			model.guiOpen = true;

			var gui:Gui = Config.inject(Gui);
			gui.setPage(EditPersonProfilePage.NAME, person, joinType, from)
		}
	}
}
