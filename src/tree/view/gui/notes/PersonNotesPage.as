package tree.view.gui.notes {
	import com.somewater.storage.I18n;

	import tree.common.Config;

	import tree.view.gui.*;
	import com.somewater.display.CorrectSizeDefinerSprite;

	import fl.containers.ScrollPane;
	import fl.controls.ScrollPolicy;

	import flash.display.Sprite;
	import flash.events.Event;

	import tree.common.Config;
	import tree.model.GenNode;
	import tree.model.Join;
	import tree.model.Model;
	import tree.model.ModelBase;
	import tree.model.Person;
	import tree.signal.ViewSignal;

	public class PersonNotesPage extends PageBase{

		public static const NOTE_WIDTH:int = Config.GUI_WIDTH;
		public static const NOTE_HEIGHT:int = 65;
		public static const NOTE_ICON_Y:int = 30;
		public static const CHANGE_TIME:Number = 0.3;


		private var model:Model;
		private var notesHolder:Sprite;
		private var firstNote:PersonNoteItem;
		private var notes:Array = [];
		private var vbox:VBoxController;

		private var selectedNote:PersonNoteItem;

		private var searchField:SearchField;
		private var scroller:ScrollPane;

		public function PersonNotesPage() {
			this.model = Config.inject(Model);

			searchField = new SearchField();
			searchField.x = (Config.GUI_WIDTH - searchField.width) * 0.5;
			searchField.addEventListener(Event.CHANGE, onSearchWordChanged);
			addChild(searchField);

			vbox = new VBoxController(notesHolder);
			vbox.filter(filterNotes);
			vbox.addEventListener(Event.CHANGE, onResize);

			notesHolder = new NotesHolder(vbox);

			scroller = new ScrollPane();
			scroller.horizontalScrollPolicy = ScrollPolicy.OFF;
			scroller.width = Config.GUI_WIDTH;
			scroller.height = 400;
			scroller.y = searchField.y + searchField.height + 8 + PersonNotesPage.NOTE_HEIGHT;
			addChild(scroller);
			scroller.source = notesHolder;
			scroller.verticalLineScrollSize = PersonNotesPage.NOTE_HEIGHT * 3;

			constructNotes();

			model.bus.addNamed(ViewSignal.DRAW_JOIN, addNote)
			model.bus.addNamed(ViewSignal.REMOVE_JOIN, removeNote)
			model.bus.addNamed(ViewSignal.PERSON_SELECTED, onSelectNodeSignal);
		}

		private function onResize(event:Event):void{
			scroller.update();
		}

		override public function clear():void {
			super.clear();
			model.bus.removeNamed(ViewSignal.DRAW_JOIN, addNote);
			model.bus.removeNamed(ViewSignal.REMOVE_JOIN, removeNote);
			model = null;

			vbox.removeEventListener(Event.CHANGE, onResize);
			searchField.removeEventListener(Event.CHANGE, onSearchWordChanged);
			searchField.clear();
			for each(var n:PersonNoteItem in notes)
				n.clear();
			if(firstNote){
				firstNote.clear();
				firstNote = null;
			}
		}

		override protected function refresh():void {
			super.refresh();
			scroller.height = _height - scroller.y;
			scroller.update();
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

			note.data = join;
			var noteName:String = join.associate.fullname;

			if(!firstNote){
				firstNote = note;
				addChildAt(note, getChildIndex(scroller));
				note.x = scroller.x;
				note.y = scroller.y - note.height;
				note.visible = true;
				note.addEventListener(Event.RESIZE, onFirstNoteResized);
			}else{
				var index:int = notes.length;
				var notesLen:int = notes.length;
				for(var i:int = 0;i<notesLen;i++)
					if(noteName < (notes[i] as PersonNoteItem).data.associate.fullname){
						index = i;
						break;
					}

				notes.splice(index, 0, note);
				notesHolder.addChildAt(note, index);
				vbox.addChildAt(note, index);
			}

			//note.over.add(selectNote);
			//note.out.add(deselectNote);
			note.click.add(selectNote);
			note.dblClick.add(centreNote);
			note.actionClick.add(openNote);
			vbox.refresh();
			fireResize();
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
					if(selectedNote == note)
						selectedNote = null;
					break;
				}
			}
			vbox.refresh();
			fireResize();
		}

		private function selectNote(note:PersonNoteItem):void {
			bus.dispatch(ViewSignal.PERSON_SELECTED, note.data.associate);
			bus.dispatch(ViewSignal.PERSON_CENTERED, note.data.associate);
		}

		private function onSelectNodeSignal(person:Person):void {
			var note:PersonNoteItem;
			for each(var n:PersonNoteItem in notes.concat(firstNote))
				if(n.data.id == person.id){
					note = n;
				}

			if(selectedNote != note){
				if(selectedNote){
					deselectNote(selectedNote);
				}
				selectedNote = note;
				if(note){
					note.selected = true;

					if(note != firstNote){
						// перематываем, чтобы note была в области видимости
						if(note.y + note.height > scroller.verticalScrollPosition + scroller.height)
							scroller.verticalScrollPosition = note.y + note.height - scroller.height;
						else if(scroller.verticalScrollPosition > note.y)
							scroller.verticalScrollPosition = note.y;
					}
				}
			}
		}

		private function deselectNote(note:PersonNoteItem):void {
			if(selectedNote == note){
				if(note){
					note.selected = false;
					bus.dispatch(ViewSignal.PERSON_DESELECTED, note.data.associate);
				}
				selectedNote = null;
			}
		}

		private function centreNote(note:PersonNoteItem):void{
			bus.dispatch(ViewSignal.PERSON_CENTERED, note.data.associate);
		}

		private function openNote(note:PersonNoteItem):void{
			var open:Boolean = !note.opened;
			if(open)
				selectNote(note);
			note.opened = open;
			fireResize();
		}

		private function onSearchWordChanged(event:Event):void{
			vbox.refresh();
		}

		private function filterNotes(note:PersonNoteItem, index:int):Boolean{
			var search:String = searchField.search.toLowerCase();
			var spaces:RegExp = /^\s+$/;
			if(search && search.length && !spaces.test(search)){
				var p:Person = note.data.associate;
				if(p.firstName.toLowerCase().indexOf(search) != -1)
					return true;
				if(p.lastName.toLowerCase().indexOf(search) != -1)
					return true;
				if(note.post.toLowerCase().indexOf(search) != -1)
					return true;
				return false;
			} else
				return true;
		}

		private function onFirstNoteResized(event:Event):void{
			scroller.y = firstNote.y + firstNote.calculatedHeight;
			refresh();
		}
	}
}

import flash.display.Sprite;

import tree.view.gui.VBoxController;

class NotesHolder extends Sprite{

	private var vbox:VBoxController;

	public function NotesHolder(vbox:VBoxController){
		this.vbox = vbox;
	}


	override public function get height():Number {
		return vbox.calculatedHeight;
	}
}
