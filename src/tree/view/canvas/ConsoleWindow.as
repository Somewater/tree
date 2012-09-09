package tree.view.canvas {
	import com.somewater.text.EmbededTextField;

	import flash.events.Event;

	import flash.events.MouseEvent;
	import flash.system.System;

	import tree.common.Config;

	import tree.view.Window;
	import tree.view.WindowsManager;

	public class ConsoleWindow extends Window{

		private static var inst:Window;

		public function ConsoleWindow() {
			setSize(300, 120)

			graphics.beginFill(0xFFFFFF);
			graphics.lineStyle(1, 0x51BBEC);
			graphics.drawRect(0, 0, width, height);

			var _array:Array = [70, 178, 20, 135, 239, 16, 116, 217, 80, 181, 34, 145, 2, 103, 217, 20, 52, 132, 229,
								92, 193, 46, 78, 156, 253, 119, 219, 65, 175, 31, 149, 181, 30, 146, 7, 119, 177, 224,
								16, 113, 228, 75, 183, 25, 140, 244, 35, 149, 11, 21]
			include '../../common/DecodingTextInclude.as';

			var tf:EmbededTextField = new EmbededTextField(null, 0, 14, false, true, true);
			tf.text = _string
					+ "\nCPU " + System.processCPUUsage
					+ "\nMEM " + Number(System.totalMemory/1024).toFixed(2) + 'kb'
					+ "\nVER " + System.vmVersion;
			tf.width = width;
			tf.x = (width - tf.textWidth) * 0.5;
			tf.y = (height - tf.height) * 0.5;
			addChild(tf);

			if(inst)
				WindowsManager.instance.remove(inst);
			open();
			inst = this;

			Config.stage.addEventListener(MouseEvent.CLICK, function(event:Event):void{close();})
		}
	}
}
