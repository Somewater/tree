package tree.command {
import com.junkbyte.console.Cc;

import flash.display.Bitmap;
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
					area.scaleX = area.scaleY = Math.min(pj.pageWidth / area.width, pj.pageHeight / area.height)

					Cc.log("[PRINT]\narea=" + area.width + "x" + area.height + " (" + area.scaleX + ")\nPJ=" + pj.pageWidth + "x" + pj.pageHeight + "\nPAPER=" + pj.paperWidth + "x" + pj.paperHeight);

					addPrintDataToStage(area);
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
			var b:Bitmap = Tree.instance.canvas.getPrintArea();
			var s:Sprite = new Sprite();
			s.addChild(b);
			return s;
		}

		private function addPrintDataToStage(area:Sprite):void{
			detain();
			Config.ticker.callLater(releasePrintData, 50, [area]);
			area.x = -100000;
			area.y = -100000;
			Config.stage.addChild(area);
		}

		private function releasePrintData(area:Sprite):void{
			if(area.parent)
				area.parent.removeChild(area);
			release();
		}
	}
}
