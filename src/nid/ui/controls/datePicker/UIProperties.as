package nid.ui.controls.datePicker
{
import com.somewater.storage.I18n;
import com.somewater.text.EmbededTextField;

import flash.display.Bitmap;
	import flash.display.BlendMode;
	import flash.display.GradientType;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.text.Font;
	import flash.text.TextFormat;
	import flash.ui.ContextMenu;
	import fl.core.UIComponent;

import tree.view.gui.TreeTextInput;

/**
	 * ...
	 * @author Nidin Vinayak
	 */
	public class UIProperties extends UIComponent
	{
		public var isInited				:Boolean;
		public var isHidden				:Boolean;
		public var calendarIcon			:iconSprite;		
		public var dateField			:DateField;
		public var myMenu			 	:ContextMenu;
		public var oldHit		 		:* = undefined;	
		public var _font				:String = "Tahoma";
		public var embedFonts			:Boolean = false;
		public var bitmapFonts			:Boolean = true;
		public var letterSpacing		:Number = 1;// 13 if one letter per day, 1 if double
		public var MonthAndYearFontSize	:Number = 12;
		public var WeekNameFontSize		:Number = 11;
		public var DayFontSize			:Number = 10;
		public var hideOnFocusOut		:Boolean = false;
		public var _alwaysShowCalendar	:Boolean = false;
		public var maxDate:Date = new Date();
		
		protected var _prompt			:String;
		protected var _prompt_bkp		:String = "Select Date";
		protected var _dateFormat		:String = "D/M/Y";
		protected var weekdisplay		:Array;
		protected var Days				:Array;
		protected var Months			:Array	= 	I18n.arr('MONTHS');
		protected var _iconPosition		:String = "right";
		protected var _calendarPosition	:String = "right";
		protected var Calendar			:MovieClip;
		protected var CalendarPoint		:Point = new Point();
		protected var inited			:Boolean	=	false;
		protected var isHitted			:Object;
		protected var cellArray			:Array;
		protected var isToday			:Boolean	=	false;
		protected var DaysinMonth		:Array;
		protected var prevDate			:Number;
		protected var today				:Date;
		protected var todaysday			:Number;
		protected var currentyear		:Number;
		protected var currentmonth		:Number;
		protected var currentYearLabel	:TreeTextInput;
		protected var currentDateLabel	:EmbededTextField;
		protected var _selectedDate		:Date;
		protected var day_bg			:MovieClip;
		protected var hit				:Sprite;
		protected var day_txt			:EmbededTextField;
		protected var _startDay			:String = "monday";
		protected var _startID			:int = 0;
		protected var todayDateBox		:MovieClip;
		
		/*
		 * COLOR VARIABLES
		 */		
		protected var backgroundColor			:Array	=	[0xFFFFFF,0xe1efb2];
		protected var backgroundGradientType	:String	=	GradientType.RADIAL;
		protected var backgroundStrokeColor		:int	=	0xA9A9C2;
		protected var labelColor				:int	=	0;
		protected var buttonColor				:int	=	0;
		protected var disabledCellColor			:int	=	0xc5cbb1;
		protected var enabledCellColor			:int	=	0x719404;
		protected var futureCellColor			:int	=	0x899466;
		protected var TodayCellColor			:int	=	0x3a8ac0;
		protected var mouseOverCellColor		:int	=	0x0099FF;
		protected var entryTextColor			:int	=	0xffffff;

		/*
		 *	CALENDAR DIAMENSIONS VARIABLES		 
		 */	
		protected var calendarWidth			:Number		= 165;
		protected var calendarHeight		:Number		= 210;
		protected var cellWidth				:Number		= 20
		protected var cellHeight			:Number		= 20
		protected var labelWidth			:Number		= 8;
		
		public function UIProperties() 
		{
			
		}
	}

}