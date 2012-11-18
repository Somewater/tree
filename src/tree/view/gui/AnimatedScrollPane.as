package tree.view.gui {
	import fl.containers.ScrollPane;
import fl.controls.ScrollBarDirection;
import fl.events.ScrollEvent;

import flash.events.MouseEvent;

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

		override protected function handleWheel(event:MouseEvent):void {
			if (!enabled || !_verticalScrollBar.visible || contentHeight <= availableHeight) {
				return;
			}
			_verticalScrollBar.scrollPosition -= (event.delta > 0 ? 1 : -1) * verticalLineScrollSize;
			setVerticalScrollPosition(_verticalScrollBar.scrollPosition);

			dispatchEvent(new ScrollEvent(ScrollBarDirection.VERTICAL, event.delta, horizontalScrollPosition));
		}
	}
}
