package tree.view.canvas {
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.Point;

	import tree.common.Config;

	import tree.common.IClear;
	import tree.model.Person;
	import tree.view.gui.UIComponent;

	public class ArrowMenu extends UIComponent{

		private var background:DisplayObject;
		private var actionsHolder:Sprite;
		public var arrow:NodeArrow;

		public function ArrowMenu() {
			actionsHolder = new Sprite();
			addChild(actionsHolder);
		}

		public function show(arrow:NodeArrow):void{
			this.arrow = arrow;
			this.visible = true;

			if(background)
				background.parent.removeChild(background);
			background = Config.loader.createMc(arrow.data.male ? 'assets.MaleArrowMenu' : 'assets.FemaleArrowMenu');
			addChildAt(background, 0);

			var action:ArrowMenuAction;
			while(actionsHolder.numChildren){
				action = actionsHolder.removeChildAt(0) as ArrowMenuAction;
				action.clear();
			}

			var nextY:int = 10;
			var nextX:int = 5;

			for (var i:int = 0; i < 3; i++) {
				action = new ArrowMenuAction();
				action.text = 'Действие ' + (i + 1);
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

		public function refreshPosition():void{
			if(arrow){
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
