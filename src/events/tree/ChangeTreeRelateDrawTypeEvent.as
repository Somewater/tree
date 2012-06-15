package events.tree {
	
	import flash.events.Event;
	
	public class ChangeTreeRelateDrawTypeEvent extends Event {
		
		public static const CHANGE_TREE_RELATE_DRAW_TYPE_EVENT:String = "ChangeTreeRelateDrawTypeEvent";
		
		private var _drawType:int;
		
		public function ChangeTreeRelateDrawTypeEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, drawType:int = -1) {
			_drawType = drawType;
			super(type, bubbles, cancelable);
		}
		
		public function get drawType():int { return _drawType; }
		
		public override function clone():Event {			
			return new ChangeTreeRelateDrawTypeEvent(type, bubbles, cancelable, _drawType);
		}	
	}
}