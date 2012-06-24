package tree.model.base {
	import tree.model.*;
	import org.osflash.signals.ISignal;

	public interface ICollection {
		function add(model:IModel):void;

		function remove(model:IModel):void;

		function has(model:IModel):Boolean;

		function clear():void;

		function update(models:Array):void;

		function get change():ISignal;

		function get added():ISignal;

		function get removed():ISignal;

		function get iterator():Array;
	}
}
