package tree.model.base {
	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;

	import tree.model.ModelBase;

	public class ModelCollection extends ModelBase implements ICollection {

		protected var _added:Signal;
		protected var _removed:Signal;

		protected var array:Array;
		protected var hash:Array;

		protected var fireChangeIfQuantityChanged:Boolean = false;

		public function ModelCollection() {
			array = [];
			hash = [];

			super();
			_added = new Signal(IModel);
			_removed = new Signal(IModel);
		}

		public function add(model:IModel):void {
			if(!hash[model.id])
			{
				array.push(model);
				hash[model.id] = model;

				added.dispatch(model);
				if(fireChangeIfQuantityChanged)
					fireChange();
			}
		}

		public function remove(model:IModel):void {
			if(hash[model.id])
			{
				array.splice(array.indexOf(model), 1);
				delete hash[model.id];

				removed.dispatch(model);
				if(fireChangeIfQuantityChanged)
					fireChange();
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
				fireChange();
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
			fireChange();
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

		public function get length():int{
			return array.length;
		}
	}
}
