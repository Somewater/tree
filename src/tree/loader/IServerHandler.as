package tree.loader {
	public interface IServerHandler {
		function initialize():void

		function call(params:Object, onComplete:Function, onError:Function, onProgress:Function):void

		function download(file:String, onComplete:Function, onError:Function, onProgress:Function):void
	}
}
