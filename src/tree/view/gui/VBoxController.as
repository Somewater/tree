package tree.view.gui {
	import com.gskinner.motion.GTweener;

	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.geom.Point;

	import tree.common.Config;

	public class VBoxController {
		private var holder:DisplayObjectContainer;
		private var _width:int;
		private var _height:int;
		private var childrens:Array = [];
		private var refreshOrdered:Boolean = false;

		public function VBoxController(holder:DisplayObjectContainer) {
			this.holder = holder;
		}

		public function setSize(h:int, w:int):void{
			this._width = w;
			this._height = h;
			needRefresh();
		}

		public function addChildAt(child:ISize, idx:int = -1):void{
			if(childrens.indexOf(child) != -1)
				throw new Error('Already added');

			if(idx != -1)
				childrens.splice(idx, 0, child);
			else
				childrens.push(child);

			(child as DisplayObject).addEventListener(Event.RESIZE, onChildResized);
			needRefresh();
		}

		public function removeChild(child:ISize):void{
			var idx:int = childrens.indexOf(child);
			if(idx == -1)
				throw new Error('Can\'t find child');

			childrens.splice(idx, 1);
			(child as DisplayObject).removeEventListener(Event.RESIZE, onChildResized);
			needRefresh();
		}

		public function get numChildren():int{
			return childrens.length;
		}

		private function needRefresh():void{
			if(!refreshOrdered){
				refreshOrdered = true;
				Config.ticker.callLater(refresh);
			}
		}

		private function onChildResized(event:Event):void{
			needRefresh();
		}

		private function refresh():void{
			refreshOrdered = false;
			var nextY:int = 0;
			for (var i:int = 0; i < childrens.length; i++) {
				var child:DisplayObject = childrens[i];
				(child as ISize).moveTo(nextY);
				nextY += (child as ISize).calculatedHeight;
			}
		}
	}
}
