package tree.view.gui.panel {
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.geom.Point;

	import tree.common.Config;

	import tree.view.gui.Button;
	import tree.view.gui.UIComponent;

	public class DoubleButton extends UIComponent{

		public var left:Button;
		public var right:Button;

		public function DoubleButton(leftMovie:MovieClip, rightMovie:MovieClip){
			super();

			var ground:DisplayObject = Config.loader.createMc('assets.DoubleButtonGround');
			addChildAt(ground, 0);

			left = new Button(leftMovie);
			addChild(left);

			right = new Button(rightMovie);
			addChild(right);
		}

		public function onFirst():Boolean{
			return this.globalToLocal(new Point(Config.stage.mouseX, 0)).x <= 27;
		}

		override public function clear():void {
			super.clear();
			left.clear();
			right.clear();
		}
	}
}
