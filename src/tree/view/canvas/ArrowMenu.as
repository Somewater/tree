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
		private var _data:Person;

		public function ArrowMenu() {
			actionsHolder = new Sprite();
			addChild(actionsHolder);
		}

		public function show(person:Person):void{
			this._data = person;
			this.visible = true;

			if(background)
				background.parent.removeChild(background);
			background = Config.loader.createMc(person.male ? 'assets.MaleArrowMenu' : 'assets.FemaleArrowMenu');
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
		}

		public function hide():void{
			this.visible = false;
		}

		public function get data():Person {
			return _data;
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
