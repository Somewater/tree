package tree.model.base {
	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;

	public class ModelCollection implements ICollection {

		protected var _changed:Signal;
		protected var _added:Signal;
		protected var _removed:Signal;

		protected var array:Array;
		protected var hash:Array;

		public function ModelCollection() {
			array = [];
			hash = [];

			_changed = new Signal(ICollection);
			_added = new Signal(IModel);
			_removed = new Signal(IModel);
		}

		public function add(model:IModel):void {
			if(!hash[model.id])
			{
				array.push(model);
				hash[model.id] = model;

				added.dispatch(model);
				change.dispatch(this);
			}
		}

		public function remove(model:IModel):void {
			if(hash[model.id])
			{
				array.splice(array.indexOf(model), 1);
				delete hash[model.id];

				removed.dispatch(model);
				change.dispatch(this);
			}
		}

		public function has(model:IModel):Boolean {
			return hash[model.id] != null;
		}

		public function clear():void {
			if(array.length)
			{
				array = [];
				hash = [];
				change.dispatch(this);
			}
		}

		public function update(models:Array):void {
			if(array.length)
			{
				array = [];
				hash = [];
			}
			for each(var m:IModel in models)
				if(!hash[m.id])
				{
					hash[m.id] = m;
					array.push(m);
				}
			change.dispatch(this);
		}

		public function get change():ISignal {
			return _changed;
		}

		public function get added():ISignal {
			return _added;
		}

		public function get removed():ISignal {
			return _removed;
		}

		public function get iterator():Array {
			return array;
		}
	}
}
