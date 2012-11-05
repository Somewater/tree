package tree.view.canvas {
	import com.somewater.storage.I18n;
import com.somewater.text.EmbededTextField;
import com.somewater.text.LinkLabel;

import flash.display.Bitmap;

import flash.display.Bitmap;
import flash.display.BitmapData;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.MovieClip;
import flash.display.Shape;
import flash.display.Sprite;
	import flash.geom.Point;

	import org.osflash.signals.Signal;

import tree.Tree;

import tree.common.Bus;

import tree.common.Config;

	import tree.common.IClear;
	import tree.model.Join;
	import tree.model.JoinType;
	import tree.model.Person;
	import tree.model.Person;
import tree.view.gui.Button;
import tree.view.gui.UIComponent;
import tree.view.window.MessageWindow;

public class ContextMenu extends UIComponent{

		private var background:Shape;
		private var actionsHolder:Sprite;

		public var actionClick:Signal;
		public var menuHided:Signal;
		public var editPersonClick:Signal;// callback(p:Person)
		public var addPhotoClick:Signal;// callback(p:Person)
		public var deletePersonClick:Signal;// callback(p:Person)

		private var fatherBtn:Button;
		private var motherBtn:Button;
		private var sisterBtn:Button;
		private var brotherBtn:Button;
		private var wifeBtn:Button;
		private var husbandBtn:Button;
		private var sonBtn:Button;
		private var daughterBtn:Button;

		private var fatherLine:DisplayObject;
		private var motherLine:DisplayObject;
		private var sisterLine:DisplayObject;
		private var brotherLine:DisplayObject;
		private var marryLine:DisplayObject;
		private var sonLine:DisplayObject;
		private var daughterLine:DisplayObject;

		private var core:MovieClip;
		private var node:NodeIcon

		private var closeBtn:Button;

		private var actionsLabel:EmbededTextField;
		private var editAction:ArrowMenuAction;
		private var addPhotoAction:ArrowMenuAction;
		private var deleteAction:ArrowMenuAction;

		public function ContextMenu() {
			background = new Shape();
			addChild(background);

			actionsHolder = new Sprite();
			addChild(actionsHolder);

			actionClick = new Signal(Person, JoinType)
			menuHided = new Signal(ContextMenu);
			editPersonClick = new Signal(Person);
			addPhotoClick = new Signal(Person);
			deletePersonClick = new Signal(Person);

			fatherBtn = new RelationBtn(Join.FATHER,onActionClicked);
			motherBtn = new RelationBtn(Join.MOTHER,onActionClicked);
			sisterBtn = new RelationBtn(Join.SISTER,onActionClicked)
			brotherBtn = new RelationBtn(Join.BROTHER,onActionClicked)
			wifeBtn = new RelationBtn(Join.WIFE,onActionClicked)
			husbandBtn = new RelationBtn(Join.HUSBAND,onActionClicked)
			sonBtn = new RelationBtn(Join.SON,onActionClicked)
			daughterBtn = new RelationBtn(Join.DAUGHTER,onActionClicked)

			closeBtn = new Button(Config.loader.createMc('assets.ContextMenuCloseBtn'));
			closeBtn.click.add(close);

			core = Config.loader.createMc('assets.NodeContextMenuCore');
			addChild(core);

			core.father.addChild(fatherBtn);
			core.mother.addChild(motherBtn);
			core.sister.addChild(sisterBtn);
			core.brother.addChild(brotherBtn);
			core.wife.addChild(wifeBtn);
			core.husband.addChild(husbandBtn);
			core.son.addChild(sonBtn);
			core.daughter.addChild(daughterBtn);

			core.close.addChild(closeBtn);

			fatherLine = core.father_line;
			motherLine = core.mother_line;
			sisterLine = core.sister_line;
			brotherLine = core.brother_line;
			marryLine = core.marry_line;
			sonLine = core.son_line;
			daughterLine = core.daughter_line;

			actionsHolder = core.actions;

			actionsLabel = new EmbededTextField(null, 0, 11, true);
			actionsLabel.text = I18n.t('ACTIONS');
			actionsHolder.addChild(actionsLabel);

			editAction = new ArrowMenuAction();
			editAction.text = I18n.t('EDIT');
			editAction.link.add(onEditClicked);
			actionsHolder.addChild(editAction);

			addPhotoAction = new ArrowMenuAction();
			addPhotoAction.text = I18n.t('ADD_PHOTO');
			addPhotoAction.link.add(onAddPhotoClicked);
			actionsHolder.addChild(addPhotoAction);

			deleteAction = new ArrowMenuAction();
			deleteAction.text = I18n.t('DELETE');
			deleteAction.link.add(onDeleteClicked);
			actionsHolder.addChild(deleteAction);

			var nextY:int = 0;
			for each(var d:DisplayObject in [actionsLabel, editAction, addPhotoAction, deleteAction]){
				d.y = nextY;
				nextY += 20;
			}
		}

		override public function clear():void {
			super.clear();
			actionClick.removeAll();
		}

		public function show(node:NodeIcon):void{
			this.node = node;
			this.visible = true;

			background.graphics.clear();
			background.graphics.beginFill(0, 0.5);
			background.graphics.drawRect(0, 0, Config.WIDTH, Config.HEIGHT);

			while(DisplayObjectContainer(core.node).numChildren) DisplayObjectContainer(core.node).removeChildAt(0);
			core.node.addChild(new Bitmap(node.drawBitmap()));

			var p:Person = node.data.join.associate;
			fatherBtn.visible = fatherLine.visible = p.father == null;
			motherBtn.visible = motherLine.visible = p.mother == null;
			sisterBtn.visible = sisterLine.visible = true;
			brotherBtn.visible = brotherLine.visible = true;
			wifeBtn.visible = p.male
			husbandBtn.visible = !p.male;
			marryLine.visible = wifeBtn.visible || husbandBtn.visible;
			sonBtn.visible = sonLine.visible = true;
			daughterBtn.visible = daughterLine.visible = true;

			deleteAction.visible = !(p.node.slaves && p.node.slaves.length)

			refreshPosition();
		}

		private function onActionClicked(action:RelationBtn):void {
			actionClick.dispatch(this.node.data.join.associate, action.type);
			close()
		}

		public function refreshPosition():void{
			var p:Point = globalToLocal(node.localToGlobal(new Point()));
			if(!isNaN(p.x) && !isNaN(p.y)){
				core.x = p.x;
				core.y = p.y;
			}
		}

		public function hide():void{
			this.visible = false;
		}

		private function  close(b:Button = null):void{
			menuHided.dispatch(this);
		}

		private function onEditClicked(a:ArrowMenuAction):void{
			editPersonClick.dispatch(node.data.join.associate);
			close()
		}

		private function onAddPhotoClicked(a:ArrowMenuAction):void{
			addPhotoClick.dispatch(node.data.join.associate);
			close()
		}

		private function onDeleteClicked(a:ArrowMenuAction):void{
			deletePersonClick.dispatch(node.data.join.associate);
			close()
		}
	}
}

import com.somewater.storage.I18n;
import com.somewater.text.EmbededTextField;
import com.somewater.text.LinkLabel;

import tree.common.Config;

import tree.model.JoinType;

import tree.view.gui.Button;

class ArrowMenuAction extends com.somewater.text.LinkLabel{

	public function ArrowMenuAction(){
		super(null, 0x2881c6, 12);
	}

	override public function clear():void {
		super.clear();
	}
}

class RelationBtn extends Button{

	public var type:JoinType;

	public function RelationBtn(type:JoinType, onClick:Function){
		this.type = type;

		this.movie = Config.loader.createMc(type.manAssoc ? 'assets.ContextMenuBtnMale' : 'assets.ContextMenuBtnFemale');
		this.textField = new EmbededTextField(null, 0xFFFFFF, 13, true);

		label = I18n.t(type.name.toUpperCase());
		click.add(onClick);
	}
}