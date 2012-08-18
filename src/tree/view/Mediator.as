package tree.view {
	import com.junkbyte.console.Cc;

	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.geom.Point;

	import tree.Tree;

	import tree.common.Bus;
	import tree.common.Config;
	import tree.model.Model;

	public class Mediator {

		protected var bus:Bus;
		protected var view:DisplayObject;
		protected var model:Model;

		private var viewListeners:Array = [];
		private var modelListeners:Array = []

		public function Mediator(view:DisplayObject) {
			this.view = view;
			bus = Config.inject(Bus);
			model = Config.inject(Model);

			Tree.instance.mediators.push(this);

			addViewListener(Event.ADDED_TO_STAGE, active);
			addViewListener(Event.REMOVED_FROM_STAGE, deactivate);
			if(view.parent)
				active(null);

			bus.sceneResize.add(onSceneResize);
		}

		public function clear():void {
			bus.sceneResize.remove(onSceneResize);
			clearViewListeners();
			clearModelListeners();
			view = null;
			bus = null;
			model = null;

			Tree.instance.mediators.splice(Tree.instance.mediators.indexOf(this), 1);
		}

		protected function active(event:Event):void {
			refresh();
		}

		protected function deactivate(event:Event):void {
		}

		protected function addViewListener(type:String, listener:Function):void {
			var arr:Array = viewListeners[type];
			if(!arr)
				viewListeners[type] = arr = [];
			if(arr.indexOf(listener) == -1)
			{
				arr.push(listener);
				view.addEventListener(type, listener);
			}
		}

		protected function removeViewListener(type:String, listener:Function):void {
			var arr:Array = viewListeners[type];
			if(!arr)
				viewListeners[type] = arr = [];
			if(arr.indexOf(listener) != -1)
			{
				arr.splice(arr.indexOf(listener), 1);
				view.removeEventListener(type, listener);
			}
		}

		protected function addModelListener(name:String, listener:Function):void {
			var arr:Array = modelListeners[name];
			if(!arr)
				modelListeners[name] = arr = [];
			if(arr.indexOf(listener) == -1)
			{
				arr.push(listener);
				bus.addNamed(name, listener);
			}
		}

		protected function removeModelListener(name:String, listener:Function):void {
			var arr:Array = modelListeners[name];
			if(!arr)
				modelListeners[name] = arr = [];
			if(arr.indexOf(listener) != -1)
			{
				arr.splice(arr.indexOf(listener), 1);
				bus.removeNamed(name, listener);
			}
		}

		protected function clearViewListeners():void {
			for(var type:String in viewListeners) {
				var arr:Array = viewListeners[type];
				for each(var l:Function in arr)
					view.removeEventListener(type, l);
				arr.length = 0;
			}
			viewListeners = [];
		}

		protected function clearModelListeners():void {
			for(var type:String in modelListeners) {
				var arr:Array = modelListeners[type];
				for each(var l:Function in arr)
					bus.removeNamed(type, l);
				arr.length = 0;
			}
			modelListeners = [];
		}

		protected function dispatch(...args):void
		{
			bus.dispatch.apply(null, args);
		}

		protected function onSceneResize(point:Point):void {
			Cc.log('Mediator scene resize ' + point + " " + this)
			refresh();
		}

		protected function refresh():void {
		}
	}
}
