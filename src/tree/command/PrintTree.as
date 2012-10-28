package tree.command {
	import flash.display.DisplayObject;
	import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
	import flash.printing.PrintJob;
	import flash.printing.PrintJobOptions;
import flash.printing.PrintJobOrientation;

import tree.Tree;
import tree.common.Config;

public class PrintTree extends Command{
		public function PrintTree() {
		}

		override public function execute():void {
			var pj:PrintJob = new PrintJob();
			if(pj.start()){
				var errorFlag:Boolean = false;
				try{
					var area:Sprite = getPrintAreal();
					var pjo:PrintJobOptions = new PrintJobOptions(false);
					if(pj.orientation == PrintJobOrientation.PORTRAIT)
						area.rotation = -90;
					area.scaleX = area.scaleY = Math.min(pj.paperWidth / area.width, pj.paperHeight / area.height)
					pj.addPage(area, null, pjo);
				}catch(err:Error){
					error(err.toString());
					message(err.toString());
					errorFlag = true;
				}
				if(!errorFlag){
					pj.send();
				}
			}
		}

		private function getPrintAreal():Sprite{
			return Tree.instance.canvas.getPrintArea();
		}
	}
}
