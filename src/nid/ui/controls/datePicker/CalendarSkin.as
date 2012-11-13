package nid.ui.controls.datePicker
{

import com.somewater.storage.I18n;
import com.somewater.text.EmbededTextField;

import flash.display.Bitmap;
import flash.events.Event;
import flash.events.MouseEvent;
	import flash.display.Sprite;
	import flash.display.MovieClip;
	import flash.display.GradientType;
	import flash.display.InterpolationMethod;
	import flash.display.SpreadMethod;
	import flash.filters.GlowFilter;
	import flash.display.BlendMode;
import flash.text.TextFormat;
import flash.text.TextFormat;
	import flash.text.TextFieldAutoSize;
	import flash.text.AntiAliasType;
	import flash.geom.Matrix;
	import flash.filters.ColorMatrixFilter;
	import nid.events.CalendarEvent;

import tree.model.Model;

import tree.view.gui.TreeTextInput;

/**
	 * ...
	 * @author Nidin Vinayak
	 */
	public dynamic class CalendarSkin extends UIProperties {
		
		/*
		 *	GET SET METHODS
		 * 
		 */
		public function set WeekStart(s:String):void 
		{ 
			_startDay = s.toLowerCase();
			if (_startDay == "monday") _startID = 0;
			else if (_startDay == "sunday")_startID = 1;
			ConstructCalendar();
		}
		public function set icon(b:Object):void { calendarIcon.configIcon(b); }
		public function set setBackgroundColor(color:Array):void { backgroundColor = color; re_construct();}
		public function set setBackgroundGradientType(value:String):void { backgroundGradientType = value; re_construct(); }
		public function set setBackgroundStrokeColor(color:int):void { backgroundStrokeColor = color; re_construct();}
		public function set setLabelColor(color:int):void { labelColor = color; re_construct();}
		public function set setButtonColor(color:int):void { buttonColor = color; re_construct();}
		public function set setDisabledCellColor(color:int):void { disabledCellColor = color; ConstructCalendar();}
		public function set setEnabledCellColor(color:int):void { enabledCellColor = color; ConstructCalendar();}
		public function set setTodayCellColor(color:int):void { TodayCellColor = color; changeColor(todayDateBox, color); }
		public function set setMouseOverColor(color:int):void { mouseOverCellColor = color;}
		public function set setDateColor(color:int):void { entryTextColor = color; ConstructCalendar();}
		
		public function set setCalendarWidth(w:Number):void { calendarWidth = w; re_construct();}
		public function set setCalendarHeight(h:Number):void { calendarHeight = h; re_construct();}			
		
		/*
		 * SET FONT SIZE
		 * 
		 */
		public function fontSize(MonthAndYear:Number = 12, WeekName:Number = 12, Day:Number = 10):void {			
			MonthAndYearFontSize = MonthAndYear;
			WeekNameFontSize = WeekName;
			DayFontSize = Day;
			if (stage)
			{
				ConstructCalendar();
			}
		}
		/*
		 * SET GLOW FILTER OF CALENDAR
		 * 
		 */
		public function setGlow(color:uint=0,alpha:Number=0.2,blurX:Number=6,blurY:Number=6,strength:Number=2,quality:int=1,inner:Boolean=false,knockout:Boolean=false):void {
			var filter:GlowFilter = new GlowFilter(color, alpha, blurX, blurY, strength, quality, inner, knockout);
			Calendar.filters = new Array(filter);
		}
		/*
		 *	MAIN
		 * 
		 */
		public function CalendarSkin() {
			
		}
		protected function re_construct():void { 
			if (stage)
			{
				Construct();
				dispatchEvent(new CalendarEvent(CalendarEvent.UPDATE));
			}
		}
		protected function Construct():void 
		{
			flush();
			Calendar = new MovieClip();
			isHitted = new Object();
			Calendar.alpha 	= 0;
			Calendar.cacheAsBitmap = true;
			setGlow();
			/*
			 *  DRAW CALENDAR BACKGROUND
			 */
			var bg						:Sprite 	= 	new Sprite();
			var type					:String 	= 	backgroundGradientType;
			var colorArray				:Array 		= 	backgroundColor;	
			var alphaArray				:Array 		=	[1,1];					
			var ratioArray				:Array		=	[0, 255];				
			var colorMatrix				:Matrix		=	new Matrix();			
			var spreadMethod			:String 	= 	SpreadMethod.PAD;		
			var interpolationMethod		:String		=	InterpolationMethod.LINEAR_RGB;
			var focalPointRatio			:Number		=	0;
			var bgStrokeColor			:int		=	backgroundStrokeColor;
			var bgStrokeThickness		:Number		=	1;
			var bgWidth					:Number		=	calendarWidth;
			var bgHeight				:Number		=	calendarHeight;
			
			colorMatrix.createGradientBox(bgWidth,bgHeight,0,0,0);
			
			bg.name 	= 	"background";
			
			bg.graphics.lineStyle(bgStrokeThickness, bgStrokeColor);			
			bg.graphics.beginGradientFill(
			  type,
			  colorArray,
			  alphaArray,
			  ratioArray,
			  colorMatrix,
			  spreadMethod,
			  interpolationMethod,
			  focalPointRatio
			  );
			  
			bg.graphics.drawRect(0,0,calendarWidth,calendarHeight);
			bg.graphics.endFill();
			
			Calendar.addChild(bg);
			
			/*
			 *	MAKE CURRENT DATE DISPLAY
			 *
			 */
				currentDateLabel		 		= 	new EmbededTextField();
				currentDateLabel.embedFonts 	=	embedFonts;
				currentDateLabel.name 			= 	"currentDateLabel";
				currentDateLabel.autoSize		=	TextFieldAutoSize.CENTER;
				currentDateLabel.selectable 	=	false;
				currentDateLabel.width			=	66;
				currentDateLabel.y				=	36;
				
			var format:TextFormat 	= 	new TextFormat();
				format.font			=	_font;
				format.color		=	labelColor;
				format.size			=	MonthAndYearFontSize;
				format.bold			=	true;
				
			currentDateLabel.defaultTextFormat	=	format;
			currentDateLabel.text				=	"";
			
		 
			/**
			 * MAKE WEEK DISPLAY
			 */
				format.letterSpacing 			=	letterSpacing;
				format.size						=	WeekNameFontSize;
				weekdisplay						=	[I18n.arr('WEEK_DAYS_SINCE_MON').join(' '),I18n.arr('WEEK_DAYS_SINCE_SON').join(' ')]
			
			Calendar.addChild(currentDateLabel);

			var nextX:int = 8;
			for each(var dName:String in I18n.arr('WEEK_DAYS_SINCE_MON')){
				var w:EmbededTextField = new EmbededTextField(null, 0, WeekNameFontSize, true);
				w.setAbstractFormatField('letterSpacing', letterSpacing)
				w.x = nextX;
				w.y = 55;
				w.text = dName;
				nextX += 22;
				Calendar.addChild(w);
			}

			currentYearLabel = new TreeTextInput();
			currentYearLabel.addEventListener(Event.CHANGE, onTextFieldChanged, false, 0, true);
			currentYearLabel.restrict = '0123456789';
			currentYearLabel.maxChars = 4;
			currentYearLabel.setStyle('textPadding', 2);
			var tf:TextFormat = EmbededTextField.getEmbededFormat();
			tf.size = 13;
			tf.align = 'center';
			currentYearLabel.setStyle('textFormat', tf)
			currentYearLabel.width = bgWidth - 100;
			currentYearLabel.x = 50;
			currentYearLabel.y = 8;
			Calendar.addChild(currentYearLabel);

			
		/*
		 *	MAKE MONTH CHANGER BUTTONS
		 */
			var nextBtn:Sprite 	= 	makeBtn(90, false);
				nextBtn.name 	= 	"NextButton";
				nextBtn.x 		= 	160; 
				nextBtn.y 		= 	41;
			var prevBtn:Sprite 	= 	makeBtn(270, false);
				prevBtn.name 	= 	"PrevButton";
				prevBtn.x 		= 	5; 
				prevBtn.y 		=	48;
				
				nextBtn.buttonMode 	= 	true;
				prevBtn.buttonMode	=	true;
				
			nextBtn.addEventListener(MouseEvent.CLICK, clickHandler, false, 0, true);
			prevBtn.addEventListener(MouseEvent.CLICK, clickHandler, false, 0, true);
			
			Calendar.addChild(nextBtn);
			Calendar.addChild(prevBtn);


			var prevYearBtn:Sprite = makeBtn(270, true);
			prevYearBtn.name 	= 	"PrevYearButton";
			prevYearBtn.x 		= 	5;
			prevYearBtn.y 		= 	27 - 5;
			prevYearBtn.buttonMode = true;

			var nextYearBtn:Sprite = makeBtn(90, true);
			nextYearBtn.name 	= 	"NextYearButton";
			nextYearBtn.x 		= 	160;
			nextYearBtn.y 		= 	20 - 5;
			nextYearBtn.buttonMode = true;

			prevYearBtn.addEventListener(MouseEvent.CLICK, clickHandler, false, 0, true);
			nextYearBtn.addEventListener(MouseEvent.CLICK, clickHandler, false, 0, true);

			Calendar.addChild(prevYearBtn);
			Calendar.addChild(nextYearBtn);
			
			
		/*
		 *	MAKE CALENDAR ENTRIES
		 */	
			prevDate		 =	undefined;
			today			 = 	new Date();
			todaysday		 =	today.getDay();
			currentyear		 =	today.getFullYear();
			currentmonth	 =	today.getMonth();
			DaysinMonth		 =	[31, isLeapYear(currentyear)?29:28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
			
			currentDateLabel.text	=	Months[currentmonth];
			currentYearLabel.text = currentyear.toString();
			
			ConstructCalendar();
			
		}

		private function onTextFieldChanged(event:Event):void{
			var year:int = parseInt(currentYearLabel.text);
			if(year >= 1000 && year <= Model.instance.currentDate.fullYear) {
				changeYear(year, false, false);
				ConstructCalendar();
			}
		}
		
		public function flush():void 
		{
			if (this.stage != null && this.stage.contains(Calendar))
			{
				stage.removeChild(Calendar);
			}
			Calendar = null;
		}
		public function clickHandler(e:MouseEvent):void{
			switch (e.target.name) {
				case "PrevButton" :
					{
						changeMonth(-1);
						break;
					}
				case "NextButton" :
					{
						changeMonth(1);
						break;
					}
				case "NextYearButton" :
					{
						changeYear(1, true, false);
						ConstructCalendar();
						break;
					}
				case "PrevYearButton" :
					{
						changeYear(-1, true, false);
						ConstructCalendar();
						break;
					}
			}
			return;
			
		}
		/*
		 * 	MONTH CHANGER FUNCTION
		 */
		public function changeMonth(monthNum:Number):void {
			if (monthNum!=1) {
				if (currentmonth > 0) {
					currentmonth = (currentmonth - 1);
				} else {
					changeYear(-1);
				}
			} else {
				if (currentmonth < 11) {
					currentmonth = currentmonth+1;
				} else {
					changeYear(1);
				}
			}
			ConstructCalendar();
			return;
		}
		/*
		 * 	YEAR CHANGER FUNCTION
		 */
		public function changeYear(yearNum:Number, relative:Boolean = true, changeMonth:Boolean = true):void {
			currentyear = relative ? currentyear + yearNum : yearNum;
			if(changeMonth)
				if (yearNum != 1) { currentmonth = 11; } else { currentmonth = 0; }
			DaysinMonth[1] = isLeapYear(currentyear)?29:28;
			return;
		}
		
		private function isLeapYear(currentyear:Number):Boolean 
		{
			var yearDev:Number = currentyear / 4;
			var yearDevLength:Number = yearDev.toString().split(".").length;
			return yearDevLength != 1?false:true;
		}
		/*
		 *	CALENDAR CONSTRUCTOR
		 */
		public function ConstructCalendar():void{
			if(inited){
				removeEntry();				
			}
			
			var dateBox		:MovieClip;
			 	cellArray				= 	new Array();
			var xpos		:Number		=	5;
			var ypos		:Number		=	73;
			var weekCount	:Number		=	0;
			var endDate		:Date 		=	new Date(currentyear,currentmonth,_startID);			
			var endDay		:Number		=	endDate.getDay();
			var locDate		:Date		=	_selectedDate || new Date();
			isToday						=	false;	
			inited 						= 	true;
			
			if ((locDate.getMonth() == currentmonth) && (locDate.getFullYear() == currentyear)) {
				isToday		=	true;
			}
			/*
			 *	CONSTRUCT FIRST SET OF DESABLED CELLS
			 */
			if (endDay > 0) {
				var inc_1:Number = 0;
				while (inc_1 < endDay) {
					dateBox 		= 	Construct_Date_Element(disabledCellColor,inc_1,false);
					dateBox.id 		= 	disabledCellColor;
					dateBox.isToday	=	false;
					dateBox.name	=	"D"+inc_1;
					dateBox.x		=	xpos+2;
					dateBox.y		=	ypos+2;
					cellArray.push(dateBox);
				
					Calendar.addChild(dateBox);
				
					if (weekCount == 6) {
						weekCount = 0;
						ypos += 22;
						xpos = 5;
					} else {
						weekCount++;
						xpos += 22;
					}					
					inc_1++;
				}
			}
			/*
			 *	CONSTRUCT DATE ENTRY CELLS
			 */			
			var entryNum:int 		= 	1;
			currentDateLabel.text	=	Months[currentmonth];
			currentYearLabel.text = currentyear.toString();
			
			var restNum:int = endDay;

			while (restNum < 42) {
				if (entryNum <= DaysinMonth[currentmonth]) {
					if (locDate.getDate()== entryNum && isToday == true) {
						dateBox 		= 	Construct_Date_Element(TodayCellColor,entryNum,true);
						dateBox.id 		= 	TodayCellColor;
						dateBox.hitted	=	false;
						dateBox.serial	=	restNum;
						dateBox.date	=	new Date(currentyear,currentmonth,entryNum);
						dateBox.isToday	=	true;
						todayDateBox  	= dateBox;
					}else{
						/*if(dateBox.hitted){
							dateBox 		= 	Construct_Date_Element(mouseOverCellColor,entryNum,true);
							dateBox.hitted	=	true;
						}else{*/
							dateBox 		= 	Construct_Date_Element(enabledCellColor,entryNum,true);
							dateBox.hitted	=	false;
						//}						
						dateBox.id 		= 	enabledCellColor;
						
						dateBox.serial	=	restNum;
						dateBox.date	=	new Date(currentyear,currentmonth,entryNum);
						dateBox.isToday	=	false;
					}
				} else {
			/*
			 *	CONSTRUCT SECOND SET OF DESABLED DATE CELLS 
			 */			
					dateBox 		= 	Construct_Date_Element(disabledCellColor,entryNum,false);
					dateBox.id 		= 	disabledCellColor;
					dateBox.isToday	=	false;
				}
				dateBox.name	=	"D"+(restNum + inc_1);
				dateBox.x		=	xpos+2;
				dateBox.y		=	ypos+2;
				cellArray.push(dateBox);
				
				Calendar.addChild(dateBox);
				
				if (weekCount == 6) {
					weekCount = 0;
					ypos += 22;
					xpos = 5;
				} else {
					weekCount++;
					xpos += 22;
				}
				restNum++;
				entryNum++;
			}
		}
		public function removeEntry():void{
			for(var i:int=0;i<42;i++){
				if (Calendar.contains(cellArray[i])) Calendar.removeChild(cellArray[i]);
			}
			cellArray = [];
		}
		/*
		 *	DATE CELL CONSTRUCTOR FUNCTION [RETURNS MOVIECLIP] 
		 */
		public function Construct_Date_Element(cellColor:int,day:int,isEntry:Boolean):MovieClip {
				day_bg			= 	new MovieClip();
				hit				= 	new Sprite();
				day_txt			=	new EmbededTextField();
				
				day_bg.name	 	= 	"bg";
				day_txt.name 	= 	"txt";
			
			day_bg.graphics.beginFill(cellColor,1);
			day_bg.graphics.drawRect(0,0,cellWidth,cellHeight);
			day_bg.graphics.endFill();
			
			hit.graphics.beginFill(0x000000,0);
			hit.graphics.drawRect(0,0,cellWidth,cellHeight);
			hit.graphics.endFill();				
			
			day_txt.autoSize 		= TextFieldAutoSize.CENTER;
			day_txt.embedFonts      = bitmapFonts?true:embedFonts;
			//day_txt.blendMode      	=	BlendMode.LAYER;
			//day_txt.antiAliasType	= AntiAliasType.ADVANCED;
			day_txt.multiline		= false;
			day_txt.selectable 		= false;
			day_txt.width 			= cellWidth;
			day_txt.x 				= 7;
			day_txt.y 				= 2;
			
			var format:TextFormat 			
			
			if (bitmapFonts)
			{
				format					= EmbededTextField.getEmbededFormat();//new BitmapFont().txt.defaultTextFormat;
			}else
			{
				format					=	new TextFormat();
				format.font 				=	_font;
				format.bold 				=	false;
				format.size 				=	DayFontSize;
			}
			
			format.color 				=	entryTextColor;
			format.align				=	"center";
			
			day_txt.defaultTextFormat 	=	format;
			
			if(isEntry){
				day_txt.text 				=	String(day);
				hit.name 	 				= 	"hit";
				hit.buttonMode 				=	true;
			}
			
			day_bg.addChild(day_txt);
			day_bg.addChild(hit);
			
			return (day_bg);
		}	
		/*
		 *	CELL COLOR CHANGER 
		 */
		public function changeColor(mc:Sprite,color:uint):void{			
			mc.graphics.clear();
			mc.graphics.beginFill(color);
			mc.graphics.drawRect(0,0,20,20);
			mc.graphics.endFill();
		}
		/*
		 * BUTTON GRAPHICS CONSTRUCTOR
		 */
		private function makeBtn(arg2:Number, double:Boolean):Sprite
		{
			var triangleHeight:uint=6;
			var triangleShape:Sprite = new Sprite();
			var w:Number = 20;
			var h:Number = 20;
			triangleShape.graphics.clear();
			triangleShape.graphics.beginFill(0xffffff, 0);
			triangleShape.graphics.drawRect(-7, 0, w, h);
			triangleShape.graphics.endFill();
			triangleShape.graphics.lineStyle(1,buttonColor);
			triangleShape.graphics.beginFill(buttonColor);
			triangleShape.graphics.moveTo(triangleHeight/2, 5);
			triangleShape.graphics.lineTo(triangleHeight, triangleHeight+5);
			triangleShape.graphics.lineTo(0, triangleHeight+5);
			triangleShape.graphics.lineTo(triangleHeight/2, 5);
			if(double){
				var dy:int = 5;
				triangleShape.graphics.endFill();
				triangleShape.graphics.beginFill(buttonColor);
				triangleShape.graphics.moveTo(triangleHeight/2, 5 + dy);
				triangleShape.graphics.lineTo(triangleHeight, triangleHeight+5 + dy);
				triangleShape.graphics.lineTo(0, triangleHeight+5 + dy);
				triangleShape.graphics.lineTo(triangleHeight/2, 5 + dy);
			}
			triangleShape.rotation = arg2;			
			return(triangleShape);
		}
	}

}