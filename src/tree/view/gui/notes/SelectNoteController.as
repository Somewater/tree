package tree.view.gui.notes {
	import com.somewater.storage.I18n;

	import tree.model.Join;
	import tree.model.JoinType;
	import tree.model.ModelBase;
	import tree.model.Node;
	import tree.model.Person;
	import tree.signal.ModelSignal;
	import tree.signal.ViewSignal;
	import tree.view.gui.GuiControllerBase;
	import tree.view.gui.profile.PersonProfilePage;
	import tree.view.window.MessageWindow;

	/**
	 * Управляет выбором персоны (из существующих), которая станет родственником человека
	 * (выбор родственника из существующих вемто создания нового)
	 */
	public class SelectNoteController extends GuiControllerBase{

		private var page:PersonNotesPage;

		public function SelectNoteController(page:PersonNotesPage) {
			this.page = page;
			super(page);

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
			constructNotes();
		}

		private function onSelectNodeSignal(person:Person):void {
			gui.setPage(PersonProfilePage.NAME);// т.е. выключить режим редактирования ноды
		}

		private function constructNotes():void {
			page.removeAllNotes();
			page.useFirstNote = false;

			var p:Person;
			var persons:Array = [];

			// выбрать всех, кто может быть "model.editing.joinType" для "model.editing.from"
			var from:Person = model.editing.from;
			var fromNode:Node = from.node;
			var joinType:JoinType = model.editing.joinType;


			for each(p in from.tree.persons.iterator)
				if(p != from && !from.relation(p)){
					var canAdd:Boolean = false;

					//  проверяем поколение
					if(joinType.flatten){
						canAdd = p.node.generation == fromNode.generation;
					}else if(joinType.breed){
						canAdd = (p.node.generation - fromNode.generation) == 1;
					}else if(!joinType.breed){
						canAdd = (p.node.generation - fromNode.generation) == -1;
					}

					// проверяем пол
					canAdd &&= p.male == joinType.manAssoc;

					if(canAdd){
						if(joinType.superType == JoinType.SUPER_TYPE_BREED){
							// если добавляем ребенка, проверяем, что у него еще нет соответствующего родителя
							canAdd = joinType == Join.MOTHER ? (p.mother == null) : (p.father == null);
						}else if(joinType.superType == JoinType.SUPER_TYPE_PARENT){
							// если добавляем родителя, проверяем, что муж/жена from не станет вдруг братом/сестрой
							if(from.marry){
								canAdd = (p.male ? p != from.marry.father : p != from.marry.mother);
							}
						}else if(joinType.superType == JoinType.SUPER_TYPE_BRO){
							// если добавляем брата/сестру, проверим, что у него нет хотя бы одного родителя, либо один из родителей у вас общий
							if(p.mother && p.father && from.mother && from.father)
								canAdd = p.mother == from.mother || p.father == from.father;
						}
					}

					if(canAdd)
						persons.push(p);
				}

			for each(p in persons){
				addNote(p)
			}
		}

		private function addNote(p:Person):void{
			var note:PersonNoteItem = page.addNote(p);
			note.hideActions();
			note.postTF.visible = false;
			note.click.add(onNoteClicked);
		}

		private function onNoteClicked(note:PersonNoteItem):void{
			if(model.constructionInProcess){
				new MessageWindow(I18n.t('CANT_SAVE_PERSON')).open();
				return;
			}
			model.editing.editEnabled = false;
			if(model.selectedPerson == model.editing.edited)
				model.selectedPerson = null;
			new MessageWindow('TODO: спросить подтверждение и отправить на сервер новую связь').open();
			//bus.dispatch(ModelSignal.EDIT_PROFILE, note.data, model.editing.joinType, model.editing.from);
			gui.setPage(PersonProfilePage.NAME);
		}
	}
}
