package tree.view.gui {
	import flash.display.DisplayObject;

	import tree.common.Bus;

	import tree.common.Config;
	import tree.model.Model;

	public class Fold extends UIComponent{

		public static const WIDTH:int = 10;
		public static const HEIGHT:int = 56;
		public static const BACKGROUND_WIDTH:int = 8;

		private var view:DisplayObject;
		private var viewClass:String;
		private var ground:DisplayObject;

		private var _open:Boolean;

		public function Fold() {
			(Config.inject(Bus) as Bus).guiChanged.add(onGuiChanged)
			buttonMode = useHandCursor = true;
			ground = Config.loader.createMc('assets.FoldCloseGround');
			addChildAt(ground, 0);

			open = Model.instance.guiOpen;
			tabEnabled = false;
		}

		override protected function refresh():void {
			ground.height = _height;
			ground.y = -_height * 0.5;
		}

		private function setClass(clazz:String):void{
			if(viewClass != clazz){
				if(view)
					view.parent.removeChild(view);
				view = Config.loader.createMc(clazz);
				viewClass = clazz;
				addChild(view);
			}
		}


		public function get open():Boolean {
			return _open;
		}

		public function set open(value:Boolean):void {
			_open = value;
			setClass(_open ? 'assets.GuiFold_open' : 'assets.GuiFold_close');
			ground.visible = !value;
		}

		private function onGuiChanged(openValue:Boolean):void{
			this.open = openValue;
		}
	}
}
