package tree.command {
	import flash.display.StageDisplayState;

	import tree.common.Config;

	public class ToggleFullScreen extends Command{
		public function ToggleFullScreen() {
		}

		override public function execute():void {
			if(Config.stage.displayState == StageDisplayState.NORMAL)
				Config.stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			else
				Config.stage.displayState = StageDisplayState.NORMAL;
		}
	}
}
