package tree.view.gui {
	import flash.display.DisplayObject;
	import flash.filters.DropShadowFilter;
	import flash.text.TextField;

	public class Helper {
		public function Helper() {
		}

		public static function stylizeText(tf:DisplayObject):void{
			tf.filters = [new DropShadowFilter(1, 90, 0, 0.3, 3, 3)];
		}
	}
}
