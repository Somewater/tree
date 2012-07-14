package tree.loader {
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.system.ApplicationDomain;

	import tree.Tree;
	import tree.common.Config;
	import tree.common.Config;

	public class TreeLoaderBase extends Sprite implements ITreeLoader{

		protected var _serverHandler:IServerHandler;
		protected var _flashVars:Object;
		private var _domain:String;
		protected var app:Tree;
		protected var lib:Lib;
		protected var swfAds:Array;

		public function TreeLoaderBase() {

			swfAds = [ApplicationDomain.currentDomain];
			lib = new Lib(swfAds);

			if(this.stage)
				onAddedToStage();
			else
				addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}

		private function onAddedToStage(event:Event = null):void {
			if(event)
				removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);

			loadAssets();
		}

		protected function loadAssets():void {
			throw new Error('Override me')
		}

		protected function onAssetsLoaded(asset:DisplayObject):void {
			if(asset.loaderInfo)
				swfAds.push(asset.loaderInfo.applicationDomain);
			startup();
		}

		protected function startup():void {
			stage.showDefaultContextMenu = CONFIG::debug;

			Config.stage = stage;

			_flashVars = loaderInfo && loaderInfo.parameters ? loaderInfo.parameters : {};
			_domain = loaderInfo.url.substr(0, loaderInfo.url.indexOf("/", 9));
			Config.loader = this;

			_serverHandler = new ServerHandler(this.domain, this.publicPath, this.scriptPath);
			_serverHandler.initialize();

			Config.WIDTH = stage.stageWidth;
			Config.HEIGHT = stage.stageHeight;

			graphics.beginFill(0xFFFFEE);
			graphics.drawRect(0,0,Config.WIDTH, Config.HEIGHT);

			app = new Tree();
			addChild(app);
			app.startup();
		}

		public function get serverHandler():IServerHandler {
			return _serverHandler;
		}

		public function get flashVars():Object {
			return _flashVars;
		}

		public function get domain():String {
			return _domain;
		}

		public function get publicPath():String {
			return _domain + '/resources/';
		}

		public function get scriptPath():String {
			return domain + "/resources/xml/Tree2.xml";
			return "http://www.familyspace.ru/ajax/tree4.html";
		}

		public function createMc(className:String, library:String = null, instance:Boolean = true):* {
			return lib.createMc(className, library, instance);
		}
	}
}
