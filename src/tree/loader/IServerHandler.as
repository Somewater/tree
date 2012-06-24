package tree.loader {
	public interface IServerHandler {
		function initialize():void

		function call(params:Object, onComplete:Function, onError:Function):void

		function download(file:String, onComplete:Function, onError:Function):void
	}
}
