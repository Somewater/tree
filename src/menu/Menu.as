package menu { 

	import commands.menu.MenuInvoker;
	
	import flash.display.Sprite;
	
	public class Menu extends Sprite implements IUse,IDisposable {
		
		private static const SHIFT:uint = 40;
		
		private var _menuInvoker:MenuInvoker;
		
		private var _relationSetter:RelationSetter;
		private var _sortSetter:SortSetter;
		private var _treeSetter:TreeSetter;
		private var _createTreeSetter:CreateTreeSetter;
		
		public function Menu() {
			
		}
		
		public function get menuInvoker():MenuInvoker { return _menuInvoker; }
		
		/** Интерфейс */
		
		public function init():void {
			_menuInvoker = new MenuInvoker();
			
			_relationSetter = new RelationSetter(this);
			_relationSetter.init();
			
			_sortSetter = new SortSetter(this);
			_sortSetter.init();
			
			_treeSetter = new TreeSetter(this);
			_treeSetter.init();
			
			_createTreeSetter = new CreateTreeSetter(this);
			_createTreeSetter.init();
			
			_sortSetter.x = _relationSetter.width + SHIFT;
			_treeSetter.x = _sortSetter.x + _sortSetter.width + SHIFT;
			_createTreeSetter.x = _treeSetter.x + _treeSetter.width + SHIFT;
			
			addChild(_relationSetter);
			addChild(_sortSetter);
			addChild(_treeSetter);
			addChild(_createTreeSetter);
			
			update();
		}
		
		public function update():void {
			_relationSetter.update();
			_sortSetter.update();
		}
		
		public function dispose():void {
			_relationSetter.dispose();
			_sortSetter.dispose();
			_treeSetter.dispose();
			_createTreeSetter.dispose();
		}
	}
}