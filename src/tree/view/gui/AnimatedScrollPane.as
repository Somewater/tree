package tree.view.gui {
	import fl.containers.ScrollPane;

	import flash.geom.Rectangle;

	import tree.view.Tweener;

	public class AnimatedScrollPane extends ScrollPane{
		public function AnimatedScrollPane() {
		}


		override protected function setVerticalScrollPosition(scrollPos:Number, fireEvent:Boolean = false):void {
			Tweener.to(this, 0.3, {'verticalScrollPositionDirectly' : scrollPos})
		}

		public function set verticalScrollPositionDirectly(y:Number):void{
			var contentScrollRect:Rectangle = contentClip.scrollRect;
			contentScrollRect.y = y;
			contentClip.scrollRect = contentScrollRect;
		}

		public function get verticalScrollPositionDirectly():Number{
			return contentClip.scrollRect.y;
		}
	}
}
