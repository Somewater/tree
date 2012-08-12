package tree.view.gui {
	import flash.display.Sprite;

	import tree.common.Config;
	import tree.model.GenNode;
	import tree.model.Join;
	import tree.model.Model;
	import tree.model.ModelBase;
	import tree.signal.ViewSignal;

	public class PersonNotesPage extends PageBase{

		public static const NOTE_HEIGHT:int = 65;
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

			model.bus.addNamed(ViewSignal.DRAW_JOIN, addNoteSignal)
			model.bus.addNamed(ViewSignal.REMOVE_JOIN, removeNoteSignal)
		}

		override public function clear():void {
			super.clear();
			model.bus.removeNamed(ViewSignal.DRAW_JOIN, addNoteSignal);
			model.bus.removeNamed(ViewSignal.REMOVE_JOIN, removeNoteSignal);
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
				addNoteSignal(j)
			}
		}

		private function addNoteSignal(data:ModelBase):void {
			var join:Join = data is GenNode ? GenNode(data).join : data as Join;
			var note:PersonNoteItem = new PersonNoteItem();
			notes.push(note);
			notesHolder.addChild(note);
			note.data = join;
			vbox.addChildAt(note);
		}

		private function removeNoteSignal(data:ModelBase):void {
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
	}
}
