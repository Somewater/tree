package tree.view.gui {
import fl.controls.TextInput;
import fl.core.InvalidationType;

import flash.display.DisplayObject;
import flash.display.Shape;
import flash.events.Event;
import flash.events.MouseEvent;

import nid.ui.controls.DatePicker;

import tree.common.Config;

import tree.view.gui.profile.PersonProfilePage;

public class DateSelector extends TreeTextInput{

	private var icon:DisplayObject;
	private var core:DatePicker;

	public function DateSelector() {
		editable = false;
		icon = Config.loader.createMc('assets.CalendarIcon');
		addChild(icon);

		textField.selectable = false;
		textField.mouseEnabled = false;
		buttonMode = useHandCursor = true;

		// http://code.google.com/p/as3-date-picker/
		core = new DatePicker();
		core.dateField.visible = false
		core.icon = new Shape();
		core.x = -97;
		core.y = 30
		addChild(core);
		addEventListener(MouseEvent.CLICK, onClick, false, 0, true);
		core.addEventListener(Event.CHANGE, onDataChanged);
	}

	public function get date():Date {
		return core.selectedDate;
	}

	public function set date(value:Date):void {
		core.selectedDate = value;
		onDataChanged(null);
	}

	override protected function draw():void {
		super.draw();
		icon.x = _width - icon.width - 4;
		icon.y = (_height - icon.height) * .5
	}

	private function onClick(ev:Event):void{
		core.showHideCalendar(ev);
	}

	private function onDataChanged(event:Event):void{
		text = PersonProfilePage.formattedBirthday(core.selectedDate);
	}
}
}
