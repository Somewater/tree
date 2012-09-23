package tree.view.gui.profile {
	import com.somewater.storage.I18n;

	import fl.controls.RadioButton;

	import flash.events.Event;

	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;

	import tree.view.gui.UIComponent;

	public class SexSelector extends UIComponent{

		public var change:ISignal;

		private var maleRadio:RadioButton;
		private var femaleRadio:RadioButton;

		public function SexSelector() {
			maleRadio = new RadioButton();
			maleRadio.groupName = 'person_sex';
			maleRadio.label = I18n.t('MALE_CHAR');
			addChild(maleRadio);

			femaleRadio = new RadioButton();
			femaleRadio.groupName = 'person_sex';
			femaleRadio.label = I18n.t('FEMALE_CHAR');
			addChild(femaleRadio);

			change = new Signal(SexSelector);
			maleRadio.group.addEventListener(Event.CHANGE, onChange);
		}

		private function onChange(event:Event):void {
			change.dispatch(this);
		}

		override public function clear():void {
			super.clear();
			change.removeAll();
			maleRadio.group.removeEventListener(Event.CHANGE, onChange);
		}

		public function get male():Boolean{
			return maleRadio.selected;
		}

		public function set male(value:Boolean):void{
			maleRadio.selected = value;
			femaleRadio.selected = !value;
		}

		override protected function refresh():void {
			femaleRadio.x = 50;
		}
	}
}
