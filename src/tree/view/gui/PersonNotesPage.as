package tree.view.gui {
	import flash.display.Sprite;

	import tree.common.Config;
	import tree.model.GenNode;
	import tree.model.Join;
	import tree.model.Model;
	import tree.model.ModelBase;
	import tree.signal.ViewSignal;

	public class PersonNotesPage extends PageBase{

		public static const NOTE_WIDTH:int = Config.GUI_WIDTH;
		public static const NOTE_HEIGHT:int = 65;
		public static const NOTE_ICON_Y:int = 30;
		public static const CHANGE_TIME:Number = 0.3;


		private var model:Model;
		private var notesHolder:Sprite;
		private var notes:Array = [];
		private var vbox:VBoxController;

		private var selectedNote:PersonNoteItem;

		public function PersonNotesPage() {
			this.model = Config.inject(Model);

			notesHolder = new Sprite();
			addChild(notesHolder);

			vbox = new VBoxController(notesHolder);

			constructNotes();

			model.bus.addNamed(ViewSignal.DRAW_JOIN, addNote)
			model.bus.addNamed(ViewSignal.REMOVE_JOIN, removeNote)
		}

		override public function clear():void {
			super.clear();
			model.bus.removeNamed(ViewSignal.DRAW_JOIN, addNote);
			model.bus.removeNamed(ViewSignal.REMOVE_JOIN, removeNote);
			model = null;
		}

		private function constructNotes():void {
			var note:PersonNoteItem;
			while(notesHolder.numChildren){
				note =notesHolder.removeChildAt(0) as PersonNoteItem;
				note.clear();
			}

			notes = [];

			for each(var j:Join in model.joinsQueue){
				addNote(j)
			}
		}

		private function addNote(data:ModelBase):void {
			var join:Join = data is GenNode ? GenNode(data).join : data as Join;
			var note:PersonNoteItem = new PersonNoteItem();
			notes.push(note);
			notesHolder.addChild(note);
			note.data = join;
			vbox.addChildAt(note);

			//note.over.add(selectNote);
			//note.out.add(deselectNote);
			note.click.add(selectNote);
			note.dblClick.add(centreNote);
			note.actionClick.add(openNote);
		}

		private function removeNote(data:ModelBase):void {
			var join:Join = data is GenNode ? GenNode(data).join : data as Join;
			for (var i:int = 0; i < notes.length; i++) {
				var note:PersonNoteItem = notes[i];
				if(note.data == join){
					notes.splice(i, 1);
					notesHolder.removeChild(note);
					vbox.removeChild(note);
					note.clear();
					break;
				}
			}
		}

		private function selectNote(note:PersonNoteItem):void {
			if(selectedNote != note){
				if(selectedNote){
					deselectNote(selectedNote);
				}
				selectedNote = note;
				if(note){
					note.selected = true;
				}
			}
		}

		private function deselectNote(note:PersonNoteItem):void {
			if(selectedNote == note){
				if(note)
					note.selected = false;
				selectedNote = null;
			}
		}

		private function centreNote(note:PersonNoteItem):void{
			selectNote(note);
		}

		private function openNote(note:PersonNoteItem):void{
			var open:Boolean = !note.opened;
			if(open)
				selectNote(note);
			note.opened = open;

		}
	}
}
