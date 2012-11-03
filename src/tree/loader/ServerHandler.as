package tree.loader {
	import com.somewater.net.UrlQueueLoader;

	import flash.net.URLRequest;
import flash.net.URLRequestHeader;
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

		public function call(params:Object, onComplete:Function, onError:Function, onProgress:Function):void {
			var urlRequest:URLRequest

			if(params && params.action == 'q_tree' && params.uid == 0)
				urlRequest = new URLRequest(scriptPath);
			else
				urlRequest = new URLRequest("http://www.familyspace.ru/ajax.php");

			urlRequest.data = new URLVariables();
			urlRequest.method = URLRequestMethod.GET;
			for(var key:String in params)
				urlRequest.data[key] = params[key];
			urlRequest.requestHeaders.push(new URLRequestHeader('fs_login', 'mktsz@mail.ru'))
			urlRequest.requestHeaders.push(new URLRequestHeader('fs_pass', '215d8f19dd19467e3132acda126a5c73'))
			urlRequest.requestHeaders.push(new URLRequestHeader('user_id', '18985299'))
			handle(urlRequest, onComplete, onError, onProgress, false);
		}

		public function download(file:String, onComplete:Function, onError:Function, onProgress:Function):void {
			var urlRequest:URLRequest = new URLRequest(file);
			handle(urlRequest, onComplete, onError, onProgress, true);
		}

		private function handle(urlRequest:URLRequest, onComplete:Function, onError:Function, onProgress:Function, binary:Boolean):void {
			loader.load({'file':{'url':urlRequest, 'binary': binary}}, function(files:Object):void{
				onComplete(files['file']);
			}, onError, onProgress);
		}
	}
}
