package tree.view.canvas {
	import com.somewater.storage.I18n;
	import com.somewater.text.LinkLabel;

	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.Point;

	import org.osflash.signals.Signal;

	import tree.common.Config;

	import tree.common.IClear;
	import tree.model.Join;
	import tree.model.JoinType;
	import tree.model.Person;
	import tree.model.Person;
	import tree.view.gui.UIComponent;

	public class ArrowMenu extends UIComponent{

		private var background:DisplayObject;
		private var actionsHolder:Sprite;
		public var arrow:NodeArrow;
		public var actionClick:Signal;

		public function ArrowMenu() {
			actionsHolder = new Sprite();
			addChild(actionsHolder);
			actionClick = new Signal(Person, JoinType)
		}

		override public function clear():void {
			super.clear();
			clearActions();
			actionClick.removeAll();
		}

		public function show(arrow:NodeArrow):void{
			this.arrow = arrow;
			this.visible = true;

			if(background)
				background.parent.removeChild(background);
			background = Config.loader.createMc(arrow.data.male ? 'assets.MaleArrowMenu' : 'assets.FemaleArrowMenu');
			addChildAt(background, 0);

			var action:ArrowMenuAction;
			clearActions();

			var nextY:int = 10;
			var nextX:int = 5;

			var actionJoinTypes:Array = [];
			if(arrow.type == NodeArrow.PARENT){
				if(!arrow.data.father) actionJoinTypes.push(Join.FATHER);
				if(!arrow.data.mother) actionJoinTypes.push(Join.MOTHER);
			}else if(arrow.type == NodeArrow.PARALLEL){
				actionJoinTypes.push(Join.SISTER);
				actionJoinTypes.push(Join.BROTHER);
				if(arrow.data.male)
					actionJoinTypes.push(Join.WIFE);
				else
					actionJoinTypes.push(Join.HUSBAND);
			}else if(arrow.type == NodeArrow.BREED){
				actionJoinTypes.push(Join.SON);
				actionJoinTypes.push(Join.DAUGHTER);
			}else throw new Error('Type not found');

			for (var i:int = 0; i < actionJoinTypes.length; i++) {
				var j:JoinType = actionJoinTypes[i];
				action = new ArrowMenuAction();
				action.text = I18n.t('ADD_RELATIVE', {name: j.toLocaleString('genetive').toLowerCase()})
				action.data = j;
				action.link.add(onActionClicked);
				action.x = 12;
				action.y = nextY;
				nextY += action.height + 5;
				if(action.x + action.width + 12 > nextX)
					nextX = action.x + action.width + 12;
				actionsHolder.addChild(action);
			}

			background.width = nextX;
			background.height = nextY + 5;

			refreshPosition();
		}

		private function onActionClicked(action:LinkLabel):void {
			actionClick.dispatch(this.arrow.data, action.data);
		}

		public function refreshPosition():void{
			if(arrow && actionsHolder.numChildren){
				var s:Point = new Point(this.width, this.height);
				var p:Point = Config.tooltips.globalToLocal(arrow.localToGlobal(new Point(NodeArrow.SIZE, 0)));
				this.x = p.x + (arrow.type == NodeArrow.BREED || arrow.type == NodeArrow.PARENT ? -s.x * 0.5 : (arrow.data.male ? -s.x : 0));
				this.y = p.y + (arrow.type == NodeArrow.PARALLEL ? -s.y * 0.5 : (arrow.type == NodeArrow.PARENT ? -s.y : 0))
			}else
				hide();
		}

		public function hide():void{
			arrow = null;
			this.visible = false;
		}

		private function clearActions():void{
			var action:ArrowMenuAction;
			while(actionsHolder.numChildren){
				action = actionsHolder.removeChildAt(0) as ArrowMenuAction;
				action.clear();
			}
		}
	}
}

import com.somewater.text.LinkLabel;

class ArrowMenuAction extends LinkLabel{

	public function ArrowMenuAction(){
		super(null, 0x2881c6, 12);
	}

	override public function clear():void {
		super.clear();
	}
}
