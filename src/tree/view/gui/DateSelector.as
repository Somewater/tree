package tree.view.gui {
import fl.controls.TextInput;
import fl.core.InvalidationType;

import flash.display.DisplayObject;
import flash.display.Shape;
import flash.events.Event;
import flash.events.MouseEvent;

import nid.ui.controls.DatePicker;

import tree.common.Config;
import tree.model.Model;

import tree.view.gui.profile.PersonProfilePage;

public class DateSelector extends TreeTextInput{

	private var icon:DisplayObject;
	private var core:SafeDatePicker;

	private var _date:Date;

	public function DateSelector() {
		editable = false;
		icon = Config.loader.createMc('assets.CalendarIcon');
		addChild(icon);

		textField.selectable = false;
		textField.mouseEnabled = false;
		buttonMode = useHandCursor = true;

		// http://code.google.com/p/as3-date-picker/
		core = new SafeDatePicker();
		core.maxDate = Model.instance.serverTime;
		core.dateField.visible = false
		core.icon = new Shape();
		core.x = -80;
		core.y = 30
		addChild(core);
		addEventListener(MouseEvent.CLICK, onClick, false, 0, true);
		core.addEventListener(Event.CHANGE, onDataChanged);
		tabEnabled = false;
	}

	public function get date():Date {
		return core.selectedDate;
	}

	public function set date(value:Date):void {
		_date = core.selectedDate = value && !isNaN(value.date) ? value : null;
		refreshTextField();
	}

	override protected function draw():void {
		super.draw();
		icon.x = _width - icon.width - 4;
		icon.y = (_height - icon.height) * .5
	}

	private function onClick(ev:Event):void{
		if(this.enabled && core.canShow){
			core.selectedDate = _date;
			core.showHideCalendar(ev);
		}
	}

	private function onDataChanged(event:Event):void{
		_date = core.selectedDate;
		refreshTextField();
	}

	private function refreshTextField():void{
		text = PersonProfilePage.formattedBirthday(_date);
	}
}
}

import flash.events.Event;

import nid.ui.controls.DatePicker;

import tree.common.Config;

class SafeDatePicker extends DatePicker{

	public var invokeTime:uint;

	override public function showHideCalendar(e:Event):void {
		invokeTime = Config.ticker.getTimer;
		super.showHideCalendar(e);
	}

	public function get canShow():Boolean{
		return Config.ticker.getTimer - invokeTime > 5;
	}
}
