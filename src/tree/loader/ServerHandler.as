package tree.loader {
	import com.somewater.net.UrlQueueLoader;

	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;

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
			var urlRequest:URLRequest

			log("Debug!");
			if(params && params.action == 'userlist' && params.uid == 0)
				urlRequest = new URLRequest(scriptPath);
			else
				urlRequest = new URLRequest("http://old.familyspace.ru/ajax/tree4.html");

			urlRequest.data = new URLVariables();
			urlRequest.method = URLRequestMethod.GET;
			for(var key:String in params)
				urlRequest.data[key] = params[key];
			handle(urlRequest, onComplete, onError, false);
		}

		public function download(file:String, onComplete:Function, onError:Function):void {
			var urlRequest:URLRequest = new URLRequest(file);
			handle(urlRequest, onComplete, onError, true);
		}

		private function handle(urlRequest:URLRequest, onComplete:Function, onError:Function, binary:Boolean):void {
			loader.load({'file':{'url':urlRequest, 'binary': binary}}, function(files:Object):void{
				onComplete(files['file']);
			}, onError);
		}
	}
}
