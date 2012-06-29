package tree.view {
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.geom.Point;

	import tree.common.Bus;

	import tree.common.Config;
	import tree.signal.ViewSignal;

	public class WindowsManager {

		public static var instance:WindowsManager;

		private var bus:Bus;
		private var windowsLayer:DisplayObjectContainer;
		private var splashScreen:Sprite;
		private var preloader:Preloader;

		private var windows:Array = [];
		private var supressRefresh:int = 0;

		public function WindowsManager(bus:Bus, windowsLayer:DisplayObjectContainer, preloader:Preloader) {
			this.bus = bus;
			this.windowsLayer = windowsLayer;

			this.preloader = preloader;
			splashScreen = new Sprite();
			onSceneResize(null);

			bus.sceneResize.addWithPriority(onSceneResize, int.MIN_VALUE);
			bus.loaderProgress.addWithPriority(onLoaderProgress, int.MIN_VALUE);
			bus.canvas.addNamed(ViewSignal.CANVAS_CONSTRUCTION_STARTED, hideLoader);
		}

		public function add(window:IWindow):void
		{
			var wd:WindowsData;
			var w:WindowsData = new WindowsData();
			w.window = window;
			w.modal = w.modal;
			w.individual = w.individual;
			w.priority = w.priority;

			if(w.individual)
			{
				var forClose:Array = [];
				for each(wd in windows)
					if(wd.priority < w.priority)
						forClose.push(wd);

				supressRefresh++;
				for each(wd in forClose)
					remove(wd.window);
				supressRefresh--;
			}

			for (var i:int = 0; i < windows.length; i++) {
				wd = windows[i];
				if(wd.priority > w.priority)
				{
					windowsLayer.addChildAt(window as DisplayObject, windowsLayer.getChildIndex(wd as DisplayObject));
					windows.splice(i, 0, w);
					break;
				}
			}

			if((window as DisplayObject).parent == null)
			{
				windowsLayer.addChild(window as DisplayObject);
				windows.push(w);
			}

			if(supressRefresh <= 0)	refresh();
		}

		public function remove(window:IWindow):void
		{
			for each(var w:WindowsData in windows)
				if(w.window == window)
				{
					windows.splice(windows.indexOf(w), 1);
					if((w.window as DisplayObject).parent == windowsLayer)
						windowsLayer.removeChild(w.window as DisplayObject);
					break;
				}

			if(supressRefresh <= 0) refresh();
		}

		public function centre(window:IWindow):void
		{
			window.x = (Config.WIDTH - window.width) * 0.5;
			window.y = (Config.HEIGHT - window.height) * 0.5;
		}

		private function onSceneResize(size:Point = null):void {
			for each(var w:WindowsData in windows)
				centre(w.window);

			splashScreen.graphics.clear();
			splashScreen.graphics.beginFill(0xFFFFFF, 0.3);
			splashScreen.graphics.drawRect(0, 0, Config.WIDTH, Config.HEIGHT);

			if(preloader.parent)
				preloader.setSize(Config.WIDTH, Config.HEIGHT);
		}

		private function refresh():void
		{
			if(splashScreen.parent)
				windowsLayer.removeChild(splashScreen);

			for (var i:int = windows.length; i > -1; i--) {
				var w:WindowsData = windows[i];
				if(w.modal)
				{
					windowsLayer.addChildAt(splashScreen, windowsLayer.getChildIndex(w.window as DisplayObject));
					break;
				}
			}
		}

		private function onLoaderProgress(progress:Number = NaN):void {
			if(isNaN(progress))
			{
				// скрыть лоадер
				hideLoader();
			}
			else
			{
				if(preloader.parent == null)
				{
					Config.tooltips.addChildAt(preloader, 0);
					preloader.setSize(Config.WIDTH, Config.HEIGHT);
				}

				preloader.progress = progress;
			}
		}

		private function hideLoader():void {
			if(preloader.parent)
					Config.tooltips.removeChild(preloader);
		}
	}
}

import tree.view.IWindow;

class WindowsData
{
	public var window:IWindow;
	public var modal:Boolean;
	public var priority:int;
	public var individual:Boolean;
}