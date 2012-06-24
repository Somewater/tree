package tree.loader {
	import com.somewater.net.UrlQueueLoader;

	import flash.net.URLRequest;

	public class ServerHandler implements IServerHandler{

		private var publicPath:String;
		private var scriptPath:String;
		private var domain:String;// вида "http://hello.com"

		private var loader:UrlQueueLoader;

		public function ServerHandler(domain:String, publicPath:String, scriptPath:String) {
			this.domain = domain;
			this.publicPath = publicPath;
			this.scriptPath = scriptPath;
		}

		public function initialize():void {
			loader = new UrlQueueLoader();
		}

		public function call(params:Object, onComplete:Function, onError:Function):void {
			var urlRequest:URLRequest = new URLRequest(scriptPath);
			handle(urlRequest, onComplete, onError);
		}

		public function download(file:String, onComplete:Function, onError:Function):void {
			var urlRequest:URLRequest = new URLRequest(publicPath + file);
			handle(urlRequest, onComplete, onError);
		}

		private function handle(urlRequest:URLRequest, onComplete:Function, onError:Function):void {
			loader.load({'file':urlRequest}, function(files:Object):void{
				onComplete(files['file']);
			}, onError);
		}
	}
}
