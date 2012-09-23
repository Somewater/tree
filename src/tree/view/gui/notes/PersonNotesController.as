package tree.view.gui.notes {
	import tree.model.GenNode;
	import tree.model.Join;
	import tree.model.ModelBase;
	import tree.model.Person;
	import tree.signal.ViewSignal;
	import tree.view.gui.GuiControllerBase;
	import tree.view.gui.notes.PersonNoteItem;
	import tree.view.gui.notes.PersonNoteItem;

	public class PersonNotesController extends GuiControllerBase{

		private var page:PersonNotesPage;

		public function PersonNotesController(page:PersonNotesPage) {
			this.page = page;
			super(page);

			model.bus.addNamed(ViewSignal.DRAW_JOIN, onAddNoteSignal)
			model.bus.addNamed(ViewSignal.REMOVE_JOIN, onRemoveNoteSignal)
			model.bus.addNamed(ViewSignal.PERSON_SELECTED, onSelectNodeSignal);
		}

		override public function clear():void {
			this.page = null;

			model.bus.removeNamed(ViewSignal.DRAW_JOIN, onAddNoteSignal);
			model.bus.removeNamed(ViewSignal.REMOVE_JOIN, onRemoveNoteSignal);
			model.bus.removeNamed(ViewSignal.PERSON_SELECTED, onSelectNodeSignal);
			model = null;

			super.clear();
		}

		override public function start(...args):void {
			super.start(args);
			gui.switcher.list = true;
			model.editing.editEnabled = false;
			constructNotes();
			onSelectNodeSignal(model.selectedPerson);
		}

		private function constructNotes():void {
			page.removeAllNotes();

			for each(var j:Join in model.joinsQueue){
				if(j.associate.visible && !hasNote(j.associate))
					addNote(j)
			}
		}

		private function hasNote(person:Person):Boolean {
			for each(var n:PersonNoteItem in page.notes)
				if(n.data == person)
					return true;
			return false;
		}

		private function selectNote(note:PersonNoteItem):void {
			bus.dispatch(ViewSignal.PERSON_SELECTED, note.data);
			bus.dispatch(ViewSignal.PERSON_CENTERED, note.data);
		}
		
		private function centreNote(note:PersonNoteItem):void{
			bus.dispatch(ViewSignal.PERSON_CENTERED, note.data);
		}

		private function openNote(note:PersonNoteItem):void{
			var open:Boolean = !note.opened;
			if(open)
				selectNote(note);
			note.opened = open;
			page.fireResize();
		}
		
		private function onSelectNodeSignal(person:Person):void {
			if(!person) {
				if(page.selectedNote)
					deselectNote(page.selectedNote)
				page.selectedNote = null;
				return;
			}
			var note:PersonNoteItem;
			var notesQueue:Array = page.firstNote ? page.notes.concat(page.firstNote) : page.notes;
			for each(var n:PersonNoteItem in notesQueue)
				if(n.data.id == person.id){
					note = n;
				}

			if(page.selectedNote != note){
				if(page.selectedNote){
					deselectNote(page.selectedNote);
				}
				page.selectedNote = note;
				if(note){
					note.selected = true;

					if(note != page.firstNote){
						// перематываем, чтобы note была в области видимости
						if(note.y + note.height > page.scroller.verticalScrollPosition + page.scroller.height)
							page.scroller.verticalScrollPosition = note.y + note.height - page.scroller.height;
						else if(page.scroller.verticalScrollPosition > note.y)
							page.scroller.verticalScrollPosition = note.y;
					}
				}
			}
		}

		private function deselectNote(note:PersonNoteItem):void {
			if(page.selectedNote == note){
				if(note){
					note.selected = false;
					bus.dispatch(ViewSignal.PERSON_DESELECTED, note.data);
				}
				page.selectedNote = null;
			}
		}

		private function onAddNoteSignal(g:GenNode):void{
			addNote(g);
		}

		private function onRemoveNoteSignal(g:GenNode):void{
			removeNote(g);
		}

		private function addNote(m:ModelBase):void{
			var note:PersonNoteItem = page.addNote(m);
			if(page.firstNote == note && !model.selectedPerson)
				selectNote(note);

			note.click.add(selectNote);
			//note.over.add(selectNote);
			//note.out.add(deselectNote);
			note.dblClick.add(centreNote);
			note.actionClick.add(openNote);
		}

		private function removeNote(m:ModelBase):void{
			page.removeNote(m);
		}
	}
}
