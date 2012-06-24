package tree.loader {
	import flash.display.Sprite;
	import flash.events.Event;

	import tree.Tree;
	import tree.common.Config;
	import tree.common.Config;

	public class TreeLoaderBase extends Sprite implements ITreeLoader{

		protected var _serverHandler:IServerHandler;
		protected var _flashVars:Object;
		private var _domain:String;
		protected var app:Tree;

		public function TreeLoaderBase() {
			if(this.stage)
				onAddedToStage();
			else
				addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}

		private function onAddedToStage(event:Event = null):void {
			if(event)
				removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);

			startup();
		}

		protected function startup():void {
			stage.showDefaultContextMenu = CONFIG::debug;

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
			return _domain + '/resources/xml/';
		}

		public function get scriptPath():String {
			return _domain;
		}
	}
}
