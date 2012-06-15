package {
	
	import flash.display.Sprite;
	import flash.events.Event;
	
	[SWF(width="0", height="0", backgroundColor="#FFFFFF", frameRate="30")]
	
	public class ConsecutiveFamilyTree extends Sprite {
		
		public static const VERSION:String = "FamilyTree v. 0.1.2";
		public static var instance:ConsecutiveFamilyTree;
		
		public function ConsecutiveFamilyTree() {
			addEventListener(Event.ADDED_TO_STAGE, onEddedToStage);
		}
		
		private function onEddedToStage(e:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, onEddedToStage);
			instance = this;
			Initializer.instance;
		}
	}
}