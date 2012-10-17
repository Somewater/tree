package tree.command {
	import flash.display.DisplayObject;
	import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
	import flash.printing.PrintJob;
	import flash.printing.PrintJobOptions;

	import tree.Tree;
import tree.common.Config;

public class PrintTree extends Command{
		public function PrintTree() {
		}

		override public function execute():void {
			var pj:PrintJob = new PrintJob();
			if(true || pj.start()){
				var errorFlag:Boolean = false;
				try{
					var area:Sprite = getPrintAreal();
					var pjo:PrintJobOptions = new PrintJobOptions(true);
					//pj.addPage(area, getPrintSize(area), pjo);
				}catch(err:Error){
					error(err.toString());
					message(err.toString());
					errorFlag = true;
				}
				if(!errorFlag){
					//pj.send();
					Config.stage.addChild(area).addEventListener(MouseEvent.CLICK, function(ev:Event):void{
						(ev.currentTarget as DisplayObject).parent.removeChild((ev.currentTarget as DisplayObject));
					});
				}
			}
		}

		private function getPrintAreal():Sprite{
			return Tree.instance.canvas.getPrintArea();
		}

		private function getPrintSize(area:Sprite):Rectangle{
			return null//Tree.instance.canvas.getPrintSize(area);
		}
	}
}
