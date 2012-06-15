package menu {
	
	import commands.menu.ChangeTreeSortTypeCommand;
	
	import family.tree.control.TreeController;
	
	import flash.display.Sprite;
	import flash.events.Event;
	
	import ui.radio.LineInfo;
	import ui.radio.RadioLine;
	
	public class SortSetter extends Sprite implements IUse,IDisposable {
		
		public static const CHANGE_TREE_SORT_TYPE_EVENT:String = "ChangeTreeSortTypeEvent";
		
		public static const FREE_SORT_TYPE:uint = 0;
		public static const COMPARE_SORT_TYPE:uint = 1;
		
		private static const RS:Array = ["Свободное", "Автоматическое"];
		private static const RS_SHIFT:uint = 10;
		
		private static const RS_BACK_COLOR:Number = 0x660000;
		private static const RS_BACK_RADIUS:Number = 6;
		private static const RS_BACK_OUTLINE_THICKNESS:Number = 0;
		private static const RS_BACK_OUTLINE_COLOR:Number = 0x000000;
		
		private static const RS_ACTIVE_COLOR:Number = 0xCC0000;
		private static const RS_ACTIVE_RADIUS:Number = 4;
		private static const RS_ACTIVE_OUTLINE_THICKNESS:Number = 0;
		private static const RS_ACTIVE_OUTLINE_COLOR:Number = 0xAAAAAA;
		
		private var _menu:Menu;
		private var _radioLine:RadioLine;
		
		public function SortSetter(menu:Menu) {
			_menu = menu;
		}
		
		private function onChangeSortType(e:Event):void {
			Initializer.instance.log.append("Try change TreeSortType to " + _radioLine.index + "...");
			update();
		}
		
		/** Интерфейс */
		
		public function init():void {
			var radioLineInfo:LineInfo = new LineInfo(
				RS,
				[RS_BACK_COLOR,	RS_BACK_RADIUS, RS_BACK_OUTLINE_THICKNESS, RS_BACK_OUTLINE_COLOR],
				[RS_ACTIVE_COLOR, RS_ACTIVE_RADIUS, RS_ACTIVE_OUTLINE_THICKNESS, RS_ACTIVE_OUTLINE_COLOR],
				RS_SHIFT,
				Constants.COMPONENT_TEXT_FORMAT,
				true,
				Constants.FILTER_1
			);
			
			_radioLine = new RadioLine(radioLineInfo);
			_radioLine.init();
			
			_radioLine.index = TreeController.auto; // Активируем по умолчанию..
			
			_radioLine.addEventListener(RadioLine.CHANGE_EVENT, onChangeSortType);
			
			addChild(_radioLine);
		}
		
		public function update():void {
			var changeTreeSortTypeCommand:ChangeTreeSortTypeCommand = new ChangeTreeSortTypeCommand(_radioLine.index);
			_menu.menuInvoker.setCommand(changeTreeSortTypeCommand);
		}
		
		public function dispose():void {
			while(numChildren) removeChildAt(0);
			_radioLine.dispose();
			_radioLine.removeEventListener(RadioLine.CHANGE_EVENT, onChangeSortType);
			_radioLine = null;
			_menu = null;
		}
	}
}