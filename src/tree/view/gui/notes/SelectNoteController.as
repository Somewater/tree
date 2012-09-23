package tree.view.gui.notes {
	import tree.model.Join;
	import tree.model.JoinType;
	import tree.model.ModelBase;
	import tree.model.Person;
	import tree.signal.ViewSignal;
	import tree.view.gui.GuiControllerBase;

	/**
	 * Управляет выбором персоны (из существующих), которая станет родственником человека
	 * (выбор родственника из существующих вемто создания нового)
	 */
	public class SelectNoteController extends GuiControllerBase{

		private var page:PersonNotesPage;

		public function SelectNoteController(view:PersonNotesPage) {
			this.page = page;
			super(view);

			model.bus.addNamed(ViewSignal.PERSON_SELECTED, onSelectNodeSignal);
		}

		override public function clear():void {
			this.page = null;

			model.bus.removeNamed(ViewSignal.PERSON_SELECTED, onSelectNodeSignal);
			model = null;

			super.clear();
		}

		override public function start(... args):void {
			super.start(args);
			model.editing.editEnabled = true;
		}

		private function onSelectNodeSignal(person:Person):void {
			gui.setPage(PersonNotesPage.NAME);// т.е. выключить режим редактирования ноды
		}

		private function constructNotes():void {
			page.removeAllNotes();
			page.useFirstNote = false;

			var p:Person;
			var persons:Array = [];

			// выбрать всех, кто может быть "model.editing.joinType" для "model.editing.from"
			var from:Person = model.editing.from;
			var joinType:JoinType = model.editing.joinType;
			for each(p in from.tree.persons.iterator)
				if(p != from){

				}

			for each(p in persons){
				addNote(p)
			}
		}

		private function addNote(p:Person):void{
			var note:PersonNoteItem = page.addNote(p);
			note.click.add(onNoteClicked);
		}

		private function onNoteClicked(note:PersonNoteItem):void{

		}
	}
}
