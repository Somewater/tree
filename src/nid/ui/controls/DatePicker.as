package nid.ui.controls
{

import com.gskinner.motion.GTween;

import fl.core.InvalidationType;

import flash.display.DisplayObject;
import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.events.MouseEvent;
    import flash.display.SimpleButton;
	import flash.events.TouchEvent;
	import flash.geom.Point;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import flash.system.Capabilities;
	import flash.system.TouchscreenType;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;	
	import nid.events.CalendarEvent;
	import nid.ui.controls.datePicker.CalendarSkin;
	import nid.ui.controls.datePicker.DateField;
	import nid.ui.controls.datePicker.iconSprite;

import tree.view.Tweener;

/**
	 * ...
	 * @author Nidin Vinayak
	 */
	public class DatePicker extends CalendarSkin {
		
		public function get selectedDate():Date { return _selectedDate; }		
		public function set selectedDate(value:Date):void 
		{
			if(_selectedDate && value && _selectedDate.time == value.time) return;
			_selectedDate = value;
			if (value == null)
			{
				_prompt = _prompt_bkp;
				dateField.text = _prompt_bkp;
				
				_selectedDate = new Date();
				currentmonth = _selectedDate.getMonth();
				currentyear  = _selectedDate.getFullYear();
				ConstructCalendar();
				_selectedDate = null;
			}
			else
			{
				currentmonth = _selectedDate.getMonth();
				currentyear  = _selectedDate.getFullYear();
				ConstructCalendar();
				setDateField(); 
				_prompt = dateField.text;
			}
		}		
		
		public function set font(value:String):void
		{
			_font = value;
			if (currentDateLabel != null)
			{
				currentDateLabel.font = value
				ConstructCalendar();
			}
		}
		
		public function set months(value:Array):void 
		{
			Months = value;
			if (currentDateLabel != null) currentDateLabel.text	=	Months[currentmonth] + " - " + currentyear;
		}		
		
		public function set days(value:Array):void 
		{ 
			weekdisplay = value; 
		}
		
		public final function DatePicker() {
			Construct();
			dateField = new DateField();
			addChild(dateField);
			calendarIcon = new iconSprite();
			calendarIcon.addEventListener(CalendarEvent.LOADED, update);
			addChild(calendarIcon);
			addEventListener(CalendarEvent.UPDATE, update);
			this.addEventListener(Event.ADDED_TO_STAGE, updateUI);
		}
		
		private function updateUI(e:Event):void 
		{
			this.removeEventListener(Event.ADDED_TO_STAGE, updateUI);
			Construct();
			update(null);
		}
		
		protected function update(e:CalendarEvent):void {
			redraw();
			isHidden = true;
			alwaysShowCalendar = _alwaysShowCalendar;
			
			if (Capabilities.touchscreenType == TouchscreenType.NONE)
			{
				calendarIcon.addEventListener(MouseEvent.CLICK,showHideCalendar);
				Calendar.addEventListener(MouseEvent.MOUSE_OVER, onOver);
				Calendar.addEventListener(MouseEvent.MOUSE_OUT, onOut);
				Calendar.addEventListener(MouseEvent.CLICK, onClick);
			}
			else
			{
				Calendar.addEventListener(TouchEvent.TOUCH_TAP, onClick);
				calendarIcon.addEventListener(TouchEvent.TOUCH_TAP, showHideCalendar);
				Calendar.addEventListener(TouchEvent.TOUCH_OVER, onOver);
				Calendar.addEventListener(TouchEvent.TOUCH_OUT, onOut);
			}
			isInited = true;
		}
		override protected function draw():void 
		{
			redraw();
			super.draw();
		}
		/**
		 * Flash IDE properties
		 */
		/**
		 * Prompt string
		 */
		[Inspectable(defaultValue="Select Date")]
		public function get prompt():String {
			return _prompt;
		}
		public function set prompt(value:String):void {
			if (value == "") {
				_prompt = null;
			} else {
				_prompt = value;
				_prompt_bkp = value;
			}
			invalidate(InvalidationType.STATE);
		}
		/**
		 * Date format
		 */
		[Inspectable(enumeration = "D/M/Y,M/D/Y,Y/M/D,Y/D/M", defaultValue = "D/M/Y", name = "dateFormat")]
		public function set dateFormat(value:String):void
		{
			_dateFormat = value;
			invalidate(InvalidationType.SIZE);
		}
		public function get dateFormat():String
		{
			return _dateFormat;
		}
		/**
		 * Icon Placement 
		 */
		[Inspectable(enumeration="left,right", defaultValue="right", name="iconPlacement")]
		public function set iconPlacement(value:String):void
		{
			_iconPosition = value;
			invalidate(InvalidationType.SIZE);
		}
		public function get iconPlacement():String
		{
			return _iconPosition;
		}
		/**
		 * Calendar Placement
		 */
		[Inspectable(enumeration="left,right,top,bottom", defaultValue="right", name="calendarPlacement")]
		public function set calendarPlacement(value:String):void
		{
			_calendarPosition = value;
			invalidate(InvalidationType.SIZE);
		}
		public function get calendarPlacement():String
		{
			return _calendarPosition;
		}
		/**
		 * 
		 */
		protected function redraw():void 
		{
			dateField.text	=	_prompt == null?_prompt_bkp:_prompt;
			relocate();
		}
		protected function relocate():void
		{
			if (iconPlacement == "right")
			{
				dateField.x 	= 0;
				calendarIcon.x 	= dateField.width + 5;
				switch(calendarPlacement)
				{
					case "right":
					{
						CalendarPoint.x = calendarIcon.x + calendarIcon.width + 5;
						CalendarPoint.y = 0;
					}
					break;
					
					case "left":
					{
						CalendarPoint.x = - (Calendar.width - 5);
						CalendarPoint.y = 0;
					}
					break;
					
					case "top":
					{
						CalendarPoint.x = 0;
						CalendarPoint.y = -(Calendar.height + 5);
					}
					break;
					
					case "bottom":
					{
						CalendarPoint.x = 0;
						CalendarPoint.y = dateField.height + 5;
					}
					break;
				}
			}
			else
			{
				calendarIcon.x 	= 0;
				dateField.x 	= calendarIcon.width + 5;
				
				switch(calendarPlacement)
				{
					case "right":
					{
						CalendarPoint.x = dateField.x + dateField.width + 5;
						CalendarPoint.y = 0;
					}
					break;
					
					case "left":
					{
						CalendarPoint.x = - (Calendar.width - 5);
						CalendarPoint.y = 0;
					}
					break;
					
					case "top":
					{
						CalendarPoint.x = 0;
						CalendarPoint.y = -(Calendar.height + 5);
					}
					break;
					
					case "bottom":
					{
						CalendarPoint.x = 0;
						CalendarPoint.y = dateField.height + 5;
					}
					break;
				}
			}	
			var pt:Point  = this.localToGlobal(CalendarPoint);
			Calendar.x = pt.x;
			Calendar.y = pt.y;
		}
		/**
		 *  Click Handler
		 */
		public function showHideCalendar(e:Event):void {
			if (_alwaysShowCalendar) return;
			if (e.currentTarget == stage) {
				//trace(e.target.name);
				if(currentYearLabel && (e.target == currentYearLabel || currentYearLabel.contains(e.target as DisplayObject))) return;
				if(e.target.name == "hit"
						|| e.target.name == "NextYearButton" || e.target.name == "PrevYearButton"
						|| e.target.name == "NextButton" || e.target.name == "PrevButton" || e.target == calendarIcon ){
					//trace(e.currentTarget);				
					return;
				}
			}
			if (isHidden) {
				relocate();
				if(_selectedDate){
					currentyear = _selectedDate.fullYear;
					currentmonth = _selectedDate.month;
				}
				ConstructCalendar();
				stage.addChild(Calendar);
				Tweener.to(Calendar, 0.3, {alpha: 1});
				isHidden	=	false;
				try{
					if (hideOnFocusOut) stage.addEventListener(MouseEvent.MOUSE_UP, showHideCalendar);
				}catch (e:Error) {}
			}else {
				Tweener.to(Calendar, 0.2, {alpha: 0}, {onComplete:onAlhphaHideComplete});
				isHidden	=	true;
				try{
					if (hideOnFocusOut) stage.removeEventListener(MouseEvent.MOUSE_UP, showHideCalendar);
				}catch (e:Error) {}				
			}
		}
		private function onAlhphaHideComplete(g:GTween = null):void{
			stage.removeChild(Calendar);
		}
		public function set alwaysShowCalendar(value:Boolean):void
		{
			_alwaysShowCalendar  = value;
			if (value && isHidden)
			{
				isHidden	=	false;
				if (stage != null) stage.addChild(Calendar);
				Tweener.to(Calendar, 0.3, {alpha: 1});
			}
			else if(!value && !isHidden)
			{
				isHidden	=	true;
				if(stage != null && stage.contains(Calendar))
					stage.removeChild(Calendar);
				Calendar.alpha = 0;
			}
		}
		public function onOver(e:Event):void {
			if(!isHidden){
			if(e.target.name == "hit"){
				if(!e.target.parent.hitted && !e.target.parent.disabled)
				changeColor(e.target.parent,mouseOverCellColor);
			}else{
				return;
			}
			}
		}
		public function onOut(e:Event):void {
			if(!isHidden){
			if(e.target.name == "hit"){
				if(!e.target.parent.hitted)
				changeColor(e.target.parent,e.target.parent.id);
			}else{
				return;
			}
			}
		}
		public function onClick(e:Event):void {
			if(!isHidden){
				if(e.target.name == "hit"){
					if(e.target.parent.disabled) return;
					e.target.parent.hitted		=	true;
					isHitted.status 			=	true;
					isHitted.num				=	e.target.parent.serial;
					if(oldHit != undefined){
						cellArray[oldHit].hitted 	= 	false;
						changeColor(cellArray[oldHit],cellArray[oldHit].id);
					}
					oldHit			=	e.target.parent.serial;
					//selectedDate	=	new Date(e.target.parent.date.getDate()+ "/" + (currentmonth + 1) + "/" + currentyear;
					var d:Date 		= 	new Date();
					_selectedDate	=	new Date(currentyear, currentmonth, e.target.parent.date.getDate(), d.hours, d.minutes, d.seconds, d.milliseconds);
					
					setDateField();
					showHideCalendar(e);
					if(!e.target.parent.isToday){ changeColor(e.target.parent,mouseOverCellColor); }
					dispatchEvent(new CalendarEvent(CalendarEvent.CHANGE, _selectedDate));
				}else{
					return;
				}
			}
		}
		public function getDateString():String
		{
			return dateField.text;
		}
		private function setDateField():void
		{
			dateField.text	= "";
			var format:Array = _dateFormat.split("/");
			for (var i:int = 0 ; i < format.length; i++ )
			{
				switch(format[i])
				{
					case "D":format[i] = _selectedDate.getDate(); break;
					case "M":format[i] = (_selectedDate.getMonth() + 1); break;
					case "Y":format[i] = _selectedDate.getFullYear(); break;
				}
			}
			for (i = 0 ; i < format.length; i++ )
			{
				dateField.appendText(format[i] + (i < format.length - 1?"/":""));
			}
		}
	}
}