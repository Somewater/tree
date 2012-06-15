package commands.menu {
	
	import commands.ICommand;
	
	import family.tree.Tree;
	import family.tree.control.TreeController;
	
	import flash.geom.Point;
	
	import layers.control.LayerController;
	
	public class ChangeTreeCommand implements ICommand {
		
		private var _index:uint;
		
		public function ChangeTreeCommand(index:uint) {
			_index = index;
		}
		
		/** Интерфейс */
		
		public function execute():void {
			var tree:Tree = TreeController.instance.trees[_index];
			var point:Point = new Point();
			if (tree) {
				point.x = tree.border.rect.topLeft.x + tree.border.rect.width * .5;
				point.y = tree.border.rect.topLeft.y + tree.border.rect.height * .5;
				LayerController.instance.transformController.showPoint(point);
			}
		}
	}
}