package tree.view.gui.notes {
	import com.gskinner.motion.GTween;
	import com.somewater.text.EmbededTextField;

	import flash.display.GradientType;

	import flash.geom.Matrix;

	import tree.model.Person;
	import tree.view.Tweener;

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

	public class PersonNoteItem extends UIComponent implements ISize, IClear, IShowable{

		private var _data:Person;
		private var nameTF:EmbededTextField;
		public var postTF:TruncatedTextField;
		private var actionsTF:com.somewater.text.LinkLabel;
		private var actionMark:DisplayObject;

		private var bottomBorder:DisplayObject;
		private var _selected:Boolean = false;
		private var _highlighted:Boolean = false;
		private var _opened:Boolean = false;
		private var newItem:Boolean = true;
		private var background:DisplayObject;

		private var menu:NoteContextMenu;
		private var menuMask:Shape;

		public var actionClick:ISignal;

		private var highlightBack:Shape;

		public function PersonNoteItem() {
			const nameTfMaxWidth:int = Config.GUI_WIDTH - 15;
			nameTF = new EmbededTextField(null, 0x799919, 15, true);
			nameTF.x = 14;
			nameTF.y = 12;
			addChild(nameTF);
			Helper.stylizeText(nameTF);

			var nameMask:Shape = new Shape();
			addChild(nameMask);
			var mat:Matrix= new Matrix();
			var colors:Array=[0,0];
			var alphas:Array=[1,0];
			var ratios:Array=[230,255];
			mat.createGradientBox(nameTfMaxWidth,nameTfMaxWidth);
			nameMask.graphics.lineStyle();
			nameMask.graphics.beginGradientFill(GradientType.LINEAR,colors,alphas,ratios,mat);
			nameMask.graphics.drawRect(0,0,nameTfMaxWidth,50);
			nameMask.graphics.endFill();
			nameTF.mask = nameMask;
			nameMask.cacheAsBitmap = nameTF.cacheAsBitmap = true;

			postTF = new TruncatedTextField(null, 0x799919, 13, false);
			postTF.maxWidth = 225;
			postTF.x = nameTF.x;
			postTF.y = 35;
			addChild(postTF);
			Helper.stylizeText(postTF);

			bottomBorder = Config.loader.createMc('assets.GuiElementHRile');
			bottomBorder.y = PersonNotesPage.NOTE_HEIGHT;
			addChildAt(bottomBorder, 0);

			background = new Shape();
			Shape(background).graphics.beginFill(0xFFFFFF);
			Shape(background).graphics.drawRect(0, 0, PersonNotesPage.NOTE_WIDTH, PersonNotesPage.NOTE_HEIGHT);
			addChildAt(background, 0);
			background.alpha = 0;

			highlightBack = new Shape();
			highlightBack.graphics.beginFill(0x00FF00, 0.1);
			highlightBack.graphics.drawRect(0, 0, PersonNotesPage.NOTE_WIDTH, PersonNotesPage.NOTE_HEIGHT);
			addChildAt(highlightBack, 0);
			highlightBack.visible = _highlighted;

			menu = new NoteContextMenu(this);
			menu.y = PersonNotesPage.NOTE_ICON_Y;
			addChild(menu);

			menuMask = new Shape();
			addChild(menuMask);
			menu.mask = menuMask;
			menuMask.graphics.beginFill(0);
			menuMask.graphics.drawRect(160, menu.y, PersonNotesPage.NOTE_WIDTH - 160, 25);
			menuMask.graphics.drawRect(0, menu.y + 25, PersonNotesPage.NOTE_WIDTH, 500);

			actionsTF = new com.somewater.text.LinkLabel(null, 0, 11, false);
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
			actionsTF.addEventListener(com.somewater.text.LinkLabel.LINK_CLICK, onActionClicked);

			this.visible = false;
			this.buttonMode = this.useHandCursor = !selected;
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
			actionsTF.removeEventListener(com.somewater.text.LinkLabel.LINK_CLICK, onActionClicked);
			actionClick.removeAll();
			actionClick = null;
			GTweener.removeTweens(this);
		}

		public function set data(data:Person):void {
			_data = data;
			nameTF.text = data.fullname;
			postTF.text = data.post || '';
			refresh();
		}

		public function get data():Person{
			return _data;
		}

		public function get selected():Boolean {
			return _selected;
		}

		public function set selected(value:Boolean):void {
			if(_selected != value){
				_selected = value;

				if(!_selected && _opened)
					this.opened = false;

				this.buttonMode = this.useHandCursor = !value;
				refreshBackground();
			}
		}

		public function get highlighted():Boolean {
			return _highlighted;
		}

		public function set highlighted(value:Boolean):void {
			if(_highlighted != value){
				_highlighted = value;
				refreshBackground();
			}
		}

		private function refreshBackground():void{
			background.alpha = _selected ? 1 : 0;
			highlightBack.visible = _highlighted && !_selected;
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
			var time:Number = PersonNotesPage.CHANGE_TIME * (this.visible ? 0.7 : 1);
			if(newItem){
				this.visible = true;
				this.y = y;
				alpha = 0;
				Tweener.to(this, time, {alpha: 1})
			}else if(this.y != y)
				Tweener.to(this, time, {y: y});
			newItem = false;
		}

		private function onActionClicked(event:Event):void{
			actionClick.dispatch(this);
		}

		public function get post():String{
			return postTF.text;
		}

		public function show():void {
			this.visible = true;
			Tweener.to(this, PersonNotesPage.CHANGE_TIME, {scaleY: 1, alpha:1}, {onComplete: onShowComplete})
		}

		public function hide():void {
			Tweener.to(this, PersonNotesPage.CHANGE_TIME, {scaleY: 0, alpha:0.2}, {onComplete: onHideComplete})
		}

		private function onShowComplete(g:GTween = null):void{
			//this.actionsTF.visible = true;
			//this.actionMark.visible = true;
		}

		private function onHideComplete(g:GTween = null):void{
			this.visible = false;
			//this.actionsTF.visible = false;
			//this.actionMark.visible = false;
		}

		public function hideActions():void {
			actionMark.visible = false;
			actionsTF.visible = false;
		}
	}
}

import com.gskinner.motion.GTween;
import com.gskinner.motion.GTweener;
import com.somewater.display.CorrectSizeDefinerSprite;
import com.somewater.storage.I18n;
import com.somewater.text.LinkLabel;

import flash.display.DisplayObject;

import flash.display.Sprite;
import flash.events.Event;

import tree.common.Config;

import tree.common.IClear;
import tree.model.Model;
import tree.signal.ViewSignal;
import tree.view.Tweener;

import tree.view.gui.notes.PersonNoteItem;
import tree.view.gui.notes.PersonNotesPage;

class NoteContextMenu extends Sprite implements IClear{

	private var note:PersonNoteItem;
	private var background:DisplayObject;
	private var actionsHolder:Sprite;

	private static const ACTIONS:Array = [
		{text: "SEND_MESSAGE"}
		,
		{text: "FOCUSING", action: "centreOnNode"}
		,
		{text: "GOTO_PAGE"}
		,
		{text: "GOTO_FAMILY_LIST"}
	];

	public function NoteContextMenu(note:PersonNoteItem){
		this.note = note;
		this.visible = false;

		background = Config.loader.createMc('assets.PersonNoteContextMenuBg');
		addChild(background);

		actionsHolder = new CorrectSizeDefinerSprite();
		actionsHolder.y = 30;
		addChild(actionsHolder);
	}

	public function clear():void {
		note = null;
		clearActions();
	}

	public function show():void{
		constructLabels();
		visible = true;
		GTweener.removeTweens(this);
		alpha = 0.25;
		background.height = actionsHolder.y + actionsHolder.height + 10;
		y = PersonNotesPage.NOTE_ICON_Y - this.height;
		Tweener.to(this, PersonNotesPage.CHANGE_TIME, {alpha:1, y:PersonNotesPage.NOTE_ICON_Y});
	}

	public function hide():void{
		GTweener.removeTweens(this);
		Tweener.to(this, PersonNotesPage.CHANGE_TIME, {alpha:0.25, y:PersonNotesPage.NOTE_ICON_Y - this.height}, {onComplete: onHided});
	}

	private function onHided(g:GTween = null):void{
		visible = true;
	}

	private function constructLabels():void{
		clearActions();
		var l:LinkLabel;
		var nextY:int;
		for each(var data:Object in ACTIONS){
			l = new LinkLabel(null, 0x2881C6, 11);
			actionsHolder.addChild(l);
			l.x = 14;
			l.y = nextY;
			l.text = I18n.t(data['text']);
			l.data = data;
			l.addEventListener(LinkLabel.LINK_CLICK, onAction);
			nextY += l.height + 5;
		}
	}

	private function clearActions():void{
		var l:LinkLabel;
		while(actionsHolder.numChildren){
			l = actionsHolder.removeChildAt(0) as LinkLabel;
			l.clear();
			l.removeEventListener(LinkLabel.LINK_CLICK, onAction);
		}
	}

	private function onAction(event:Event):void {
		var l:LinkLabel = event.currentTarget as LinkLabel;
		var data:Object = l.data;
		if(data && data.action && this.hasOwnProperty(data.action))
			this[data.action]();
	}

	private function centreOnNode():void{
		Model.instance.bus.dispatch(ViewSignal.PERSON_CENTERED, note.data);
	}
}