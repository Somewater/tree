package events {
	
	import flash.events.Event;
	
	public class ParamEvent extends Event {
		
		private var _params:Array;
		
		public function ParamEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, params:Array = null) {
			_params = params;
			super(type, bubbles, cancelable);			
		}
		
		public function get params():Array { return _params; }
		
		public override function clone():Event {			
			return new ParamEvent(type, bubbles, cancelable, _params);
		}
	}
}