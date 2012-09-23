package tree.view.gui.notes {
	import com.somewater.storage.I18n;
	import com.somewater.text.EmbededTextField;

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

		public static const NAME:String = 'PersonNotesPage';
		public static const NAME_MODE_SELECT:String = 'PersonNotesPage_modeEditSelect';

		public static const NOTE_WIDTH:int = Config.GUI_WIDTH;
		public static const NOTE_HEIGHT:int = 65;
		public static const NOTE_ICON_Y:int = 30;
		public static const CHANGE_TIME:Number = 0.3;


		public var notesHolder:Sprite;
		public var notesHolderEmptyLabel:EmbededTextField;
		public var firstNote:PersonNoteItem;
		private var _useFirstNote:Boolean = true;
		public var notes:Array = [];
		public var vbox:VBoxController;

		public var selectedNote:PersonNoteItem;

		public var searchField:SearchField;
		public var scroller:ScrollPane;

		public function PersonNotesPage() {
			searchField = new SearchField();
			searchField.x = (Config.GUI_WIDTH - searchField.width) * 0.5;
			searchField.addEventListener(Event.CHANGE, onSearchWordChanged);
			addChild(searchField);

			vbox = new VBoxController(notesHolder);
			vbox.filter(filterNotes);
			vbox.addEventListener(Event.CHANGE, onResize);

			notesHolder = new NotesHolder(vbox);
			notesHolderEmptyLabel = new EmbededTextField(null, 0x799919, 13, false, false, false, false, 'center');
			notesHolderEmptyLabel.text = I18n.t('EMPTY');
			addChild(notesHolderEmptyLabel);

			scroller = new ScrollPane();
			scroller.horizontalScrollPolicy = ScrollPolicy.OFF;
			scroller.width = Config.GUI_WIDTH;
			scroller.height = 400;
			scroller.y = searchField.y + searchField.height + 8 + PersonNotesPage.NOTE_HEIGHT;
			addChild(scroller);
			scroller.source = notesHolder;
			scroller.verticalLineScrollSize = PersonNotesPage.NOTE_HEIGHT * 3;
		}


		override public function get pageName():String {
			return NAME;
		}

		private function onResize(event:Event):void{
			scroller.update();
		}

		override public function clear():void {
			super.clear();

			vbox.removeEventListener(Event.CHANGE, onResize);
			searchField.removeEventListener(Event.CHANGE, onSearchWordChanged);
			searchField.clear();
			for each(var n:PersonNoteItem in notes){
				notesHolder.removeChild(n);
				vbox.removeChild(n);
				n.clear();
			}
			notes = [];
			if(firstNote){
				firstNote.clear();
				firstNote.parent.removeChild(firstNote);
			}

			selectedNote = null;
			firstNote = null;
		}

		override protected function refresh():void {
			super.refresh();
			scroller.height = _height - scroller.y;
			scroller.update();
			notesHolderEmptyLabel.width = _width || 100;
			notesHolderEmptyLabel.y = searchField.y + searchField.height + PersonNotesPage.NOTE_HEIGHT * 0.5;
		}

		public function removeAllNotes():void{
			var note:PersonNoteItem;
			while(notesHolder.numChildren){
				note = notesHolder.removeChildAt(0) as PersonNoteItem;
				note.clear();
			}
			notesHolderEmptyLabel.visible = true;

			notes = [];
		}

		public function addNote(data:ModelBase):PersonNoteItem {
			var p:Person = data is GenNode ? GenNode(data).join.associate : (data is Join ? Join(data).associate : data as Person);
			var note:PersonNoteItem = new PersonNoteItem();

			note.data = p;
			var noteName:String = p.fullname;

			if(!firstNote && useFirstNote){
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
					if(noteName < (notes[i] as PersonNoteItem).data.fullname){
						index = i;
						break;
					}

				notes.splice(index, 0, note);
				notesHolder.addChildAt(note, index);
				vbox.addChildAt(note, index);
			}

			onFirstNoteResized(null);
			vbox.refresh();
			fireResize();
			notesHolderEmptyLabel.visible = notes.length == 0 && !firstNote;

			return note;
		}

		public function removeNote(data:ModelBase):PersonNoteItem {
			var p:Person = data is GenNode ? GenNode(data).join.associate : (data is Join ? Join(data).associate : data as Person);
			for (var i:int = 0; i < notes.length; i++) {
				var note:PersonNoteItem = notes[i];
				if(note.data == p){
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
			notesHolderEmptyLabel.visible = notes.length == 0 && !firstNote;
			return note;
		}

		private function onSearchWordChanged(event:Event):void{
			vbox.refresh();
		}

		private function filterNotes(note:PersonNoteItem, index:int):Boolean{
			var search:String = searchField.search.toLowerCase();
			var spaces:RegExp = /^\s+$/;
			if(search && search.length && !spaces.test(search)){
				var p:Person = note.data;
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
			scroller.y = (firstNote ? firstNote.y + firstNote.calculatedHeight : searchField.y + searchField.height + 8);
			refresh();
		}

		public function get useFirstNote():Boolean {
			return _useFirstNote;
		}

		public function set useFirstNote(value:Boolean):void {
			if(_useFirstNote != value){
				_useFirstNote = value
				scroller.y = searchField.y + searchField.height + 8 + (value ? PersonNotesPage.NOTE_HEIGHT : 0);
			}
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
