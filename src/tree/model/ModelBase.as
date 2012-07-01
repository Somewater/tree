package tree.model {
	import org.osflash.signals.ISignal;
	import org.osflash.signals.PrioritySignal;

	import tree.model.base.IModel;

	public class ModelBase implements IModel{

		/**
		 * Идет перестроение всех моделей, поэтому каждая модели не диспатчат эвентов
		 */
		public static var radioSilence:Boolean = false;

		protected var _changeSIgnal:ISignal

		public function ModelBase() {
		}

		public function get id():String {
			return null;
		}

		public function fireChange():void {
			if(!radioSilence)
				changed.dispatch(this);
		}

		public function get changed():ISignal {
			if(!_changeSIgnal)
				_changeSIgnal = new PrioritySignal(IModel);
			return _changeSIgnal;
		}
	}
}
