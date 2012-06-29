package {
	import flash.display.Loader;
	import flash.events.Event;

	import tree.loader.TreeLoaderBase;

	[Frame(factoryClass="tree.loader.Preloader")]
	[SWF(width="810", height="650", backgroundColor="#FFFFEE", frameRate="30")]
	public class TreeLoader extends TreeLoaderBase{

		[Embed(source='assets/TreeAssets.swf')]
		private var assets:Class;


		public function TreeLoader() {
		}

		override protected function loadAssets():void {
			//var loader:Loader = new Loader();
			//loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadingComplete, false, 0, true);
			//loader.loadBytes(new assets());
			onAssetsLoaded(new assets());
		}

		private function onLoadingComplete(event:Event):void {
			onAssetsLoaded(Loader(event.target).content);
		}
	}
}
