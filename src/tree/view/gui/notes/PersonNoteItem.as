package tree.view.gui.notes {
	import tree.view.gui.*;
	import com.gskinner.motion.GTweener;
	import com.somewater.storage.I18n;
	import com.somewater.text.LinkLabel;
	import com.somewater.text.TruncatedTextField;

	import flash.display.DisplayObject;
	import flash.display.Shape;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;

	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;

	import tree.common.Config;

	import tree.common.IClear;
	import tree.model.Join;

	public class PersonNoteItem extends UIComponent implements ISize, IClear{

		private var _data:Join;
		private var nameTF:TruncatedTextField;
		private var postTF:TruncatedTextField;
		private var actionsTF:LinkLabel;
		private var actionMark:DisplayObject;

		private var bottomBorder:DisplayObject;
		private var _selected:Boolean = false;
		private var _opened:Boolean = false;
		private var newItem:Boolean = true;
		private var background:DisplayObject;

		private var menu:NoteContextMenu;
		private var menuMask:Shape;

		public var actionClick:ISignal;

		public function PersonNoteItem() {
			nameTF = new TruncatedTextField(null, 0x799919, 15, true);
			nameTF.maxWidth = 225;
			nameTF.x = 14;
			nameTF.y = 12;
			addChild(nameTF);

			postTF = new TruncatedTextField(null, 0x799919, 13, false);
			postTF.maxWidth = 225;
			postTF.x = nameTF.x;
			postTF.y = 35;
			addChild(postTF);

			bottomBorder = Config.loader.createMc('assets.GuiElementHRile');
			bottomBorder.y = PersonNotesPage.NOTE_HEIGHT;
			addChildAt(bottomBorder, 0);

			background = new Shape();
			Shape(background).graphics.beginFill(0xFFFFFF);
			Shape(background).graphics.drawRect(0, 0, PersonNotesPage.NOTE_WIDTH, PersonNotesPage.NOTE_HEIGHT);
			addChildAt(background, 0);
			background.alpha = 0;

			menu = new NoteContextMenu(this);
			menu.y = PersonNotesPage.NOTE_ICON_Y;
			addChild(menu);

			menuMask = new Shape();
			addChild(menuMask);
			menu.mask = menuMask;
			menuMask.graphics.beginFill(0);
			menuMask.graphics.drawRect(135, menu.y, PersonNotesPage.NOTE_WIDTH - 135, 25);
			menuMask.graphics.drawRect(0, menu.y + 25, PersonNotesPage.NOTE_WIDTH, 500);

			actionsTF = new LinkLabel(null, 0, 13, false);
			actionsTF.text = I18n.t('ACTIONS')
			actionsTF.x = Config.GUI_WIDTH - 25 - actionsTF.width;
			actionsTF.y = postTF.y;
			addChild(actionsTF);

			actionMark = Config.loader.createMc('assets.TriangleMark');
			actionMark.x = actionsTF.x + actionsTF.width + 5;
			actionMark.y = actionsTF.y + 10;
			actionMark.rotation = 180;
			addChild(actionMark);

			actionClick = new Signal(PersonNoteItem);
			actionsTF.addEventListener(LinkLabel.LINK_CLICK, onActionClicked);

			this.visible = false;
		}

		override public function get calculatedHeight():int {
			return _opened ? PersonNotesPage.NOTE_ICON_Y + menu.height : PersonNotesPage.NOTE_HEIGHT;
		}

		override public function get height():Number {
			return calculatedHeight;
		}

		override public function clear():void {
			actionsTF.clear();
			_data = null;
			menu.clear();
			menu = null;
			super.clear();
			actionsTF.removeEventListener(LinkLabel.LINK_CLICK, onActionClicked);
			actionClick.removeAll();
			actionClick = null;
		}

		public function set data(data:Join):void {
			_data = data;
			nameTF.text = data.associate.name;
			postTF.text = data.type.toString();
			refresh();
		}

		public function get data():Join{
			return _data;
		}

		public function get selected():Boolean {
			return _selected;
		}

		public function set selected(value:Boolean):void {
			if(_selected != value){
				_selected = value;
				background.alpha = value ? 1 : 0;

				if(!_selected && _opened)
					this.opened = false;
			}
		}

		public function get opened():Boolean {
			return _opened;
		}

		public function set opened(value:Boolean):void {
			if(_opened != value){
				_opened = value;
				if(value){
					menu.show();
					actionMark.rotation = 0;
				}else{
					menu.hide();
					actionMark.rotation = 180;
				}
				fireResize();
			}
		}

		override public function moveTo(y:int):void {
			if(newItem){
				this.visible = true;
				this.y = y;
				alpha = 0;
				GTweener.to(this, PersonNotesPage.CHANGE_TIME, {alpha: 1})
			}else if(this.y != y)
				GTweener.to(this, PersonNotesPage.CHANGE_TIME, {y: y});
			newItem = false;
		}

		private function onActionClicked(event:Event):void{
			actionClick.dispatch(this);
		}

		public function get post():String{
			return postTF.text;
		}
	}
}

import com.gskinner.motion.GTween;
import com.gskinner.motion.GTweener;

import flash.display.DisplayObject;

import flash.display.Sprite;

import tree.common.Config;

import tree.common.IClear;

import tree.view.gui.notes.PersonNoteItem;
import tree.view.gui.notes.PersonNotesPage;

class NoteContextMenu extends Sprite implements IClear{

	private var note:PersonNoteItem;
	private var background:DisplayObject;

	public function NoteContextMenu(note:PersonNoteItem){
		this.note = note;
		this.visible = false;

		background = Config.loader.createMc('assets.PersonNoteContextMenuBg');
		addChild(background);
	}

	public function clear():void {
		note = null;
	}

	public function show():void{
		constructLabels();
		visible = true;
		GTweener.removeTweens(this);
		alpha = 0.25;
		y = PersonNotesPage.NOTE_ICON_Y - this.height;
		GTweener.to(this, PersonNotesPage.CHANGE_TIME, {alpha:1, y:PersonNotesPage.NOTE_ICON_Y});
	}

	public function hide():void{
		GTweener.removeTweens(this);
		GTweener.to(this, PersonNotesPage.CHANGE_TIME, {alpha:0.25, y:PersonNotesPage.NOTE_ICON_Y - this.height}, {onComplete: onHided});
	}

	private function onHided(g:GTween):void{
		visible = true;
	}

	private function constructLabels():void{

	}
}