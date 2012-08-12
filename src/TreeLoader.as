package {
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;

	import tree.loader.TreeLoaderBase;

	[Frame(factoryClass="tree.loader.Preloader")]
	[SWF(width="1000", height="950", backgroundColor="#FFFFEE", frameRate="30")]
	public class TreeLoader extends TreeLoaderBase{

		[Embed(source='assets/TreeAssets.swf', mimeType='application/octet-stream')]
		private var assets:Class;

		[Embed(source='assets/Fonts_ru.swf', mimeType='application/octet-stream')]
		private var fonts:Class;

		public function TreeLoader() {
		}

		override protected function loadAssets():void {
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(event:Event):void{
				swfAds.push(LoaderInfo(event.target).content.loaderInfo.applicationDomain);
				var loader2:Loader = new Loader();
				loader2.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadingComplete, false, 0, true);
				loader2.loadBytes(new fonts());
			}, false, 0, true);
			loader.loadBytes(new assets());
		}

		private function onLoadingComplete(event:Event):void {
			onAssetsLoaded(LoaderInfo(event.target).content);
		}
	}
}
