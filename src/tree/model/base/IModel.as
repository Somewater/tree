package tree.model.base {
	import org.osflash.signals.ISignal;

	public interface IModel {
		function get id():String;

		function fireChange():void;
		function get changed():ISignal;// callback(value:IModel)
	}
}
