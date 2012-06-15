package menu {
	
	import commands.menu.ChangeTreeCommand;
	
	import family.tree.Tree;
	import family.tree.control.TreeController;
	
	import fl.controls.ComboBox;
	import fl.controls.TextInput;
	import fl.core.InvalidationType;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	public class TreeSetter extends Sprite implements IUse,IDisposable {
		
		private static const TREE_LIST_SIZE:Point = new Point(150, 22);
		private static const SHIFT:uint = 5;
		
		private var _menu:Menu;
		
		private var _treeList:ComboBox = new ComboBox();
		private var _findButton:FindButton = new FindButton();
		
		public function TreeSetter(menu:Menu) {
			_menu = menu;
		}
		
		public function addTree(tree:Tree):void {
			
		}
		
		public function removeTree(tree:Tree):void {
			
		}
		
		private function onChangeTree(e:Event):void {
			find(null);
		}
		
		private function find(e:MouseEvent):void {
			Initializer.instance.log.append("Find and show Tree UID = " + _treeList.selectedIndex + "...");
			var changeTreeCommand:ChangeTreeCommand = new ChangeTreeCommand(_treeList.selectedIndex);
			_menu.menuInvoker.setCommand(changeTreeCommand);
		}
		
		/** Интерфейс */
		
		public function init():void {
			_treeList.setSize(TREE_LIST_SIZE.x, TREE_LIST_SIZE.y);
			
			var trees:Array = TreeController.instance.trees;
			var tree:Tree;
			
			for (var i:uint = 0; i < trees.length; i++) {
				tree = trees[i];
				_treeList.addItem(
					{
						label:tree.treeName.login.text
					}
				);
			}
			
			_treeList.addEventListener(Event.CHANGE, onChangeTree);
			
			_treeList.selectedIndex = 0;
			
			// Гребанный галюн флэшевых компонентов! Пока так....
			var tInput:TextInput = _treeList.getChildAt(1) as TextInput;
			tInput.textField.height = TREE_LIST_SIZE.y; 
			
			_findButton.x = _treeList.width + SHIFT;
			_findButton.buttonMode = true;
			_findButton.addEventListener(MouseEvent.CLICK, find);
			
			addChild(_treeList);
			addChild(_findButton);
			
			find(null);
		}
		
		public function update():void {
			
		}
		
		public function dispose():void {
			_treeList.removeEventListener(Event.CHANGE, onChangeTree);	
			_findButton.removeEventListener(MouseEvent.CLICK, find);
			
			_treeList = null;
		}
	}
}