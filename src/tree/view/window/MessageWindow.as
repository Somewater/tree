package tree.view.window {
	import com.somewater.text.EmbededTextField;

	import flash.events.Event;

	import flash.events.MouseEvent;
	import flash.system.System;

	import tree.common.Config;

	import tree.common.Config;

	import tree.view.Window;
	import tree.view.WindowsManager;

	public class MessageWindow extends Window{

		public function MessageWindow(text:String) {
			setSize(300, 120)

			var tf:EmbededTextField = new EmbededTextField(null, 0, 14, false, true, true);
			tf.text = text;
			tf.width = width - 30;
			tf.x = (width - tf.textWidth) * 0.5;
			tf.y = (height - tf.height) * 0.5;
			addChild(tf);
		}

		override public function open():void {
			Config.ticker.callLater(callOpen);
			Config.stage.addEventListener(MouseEvent.CLICK, onStageClick);
		}

		private function callOpen():void{
			super.open();
		}

		override public function clear():void {
			super.clear();
			Config.stage.removeEventListener(MouseEvent.CLICK, onStageClick);
		}

		private function onStageClick(e:Event):void{
			close();
		}
	}
}
