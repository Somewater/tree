package tree.common {
	import org.osflash.signals.ISignal;

	public interface INamedSignal extends ISignal{

		function addNamed(name:String, listener:Function):void

		function removeNamed(name:String, listener:Function):void
	}
}
