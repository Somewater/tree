package family.relation {
	
	import family.tree.Tree;
	import family.item.TreeItem;
	
	import flash.display.Sprite;
	
	public class Relations extends Sprite implements IUpdate {
		
		private static const RELATE_SHIFT:uint = 2;
		
		private var _tree:Tree;
		private var _relations:Array;
		private var _type:uint;
		
		public function Relations(tree:Tree) {
			_tree = tree;
		}
		
		public function addRelation(relation:Relation):void {
			
		}
		
		public function removeRelation(relation:Relation):void {
			
		}
		
		public function get tree():Tree { return _tree; }
		
		public function get type():uint { return _type; }
		public function set type(value:uint):void { 
			_type = value;
			update();
		}
		
		private function reDraw():void {
			while(numChildren) removeChildAt(0);
			graphics.clear();
			
			for (var i:uint = 0; i < _relations.length; i++) Relation(_relations[i]).update();
			graphics.endFill();
		}
		
		// Есть ли такой UID среди UIDs...
		private function isUID(uid:uint, uids:Array):Boolean {
			for (var i:uint = 0; i < uids.length; i++) if (uids[i] == uid) return true;
			return false;
		}
		
		private function isRelation(treeItemBegin:TreeItem, treeItemEnd:TreeItem):Boolean {
			var allChildrenUIDs:Array = treeItemBegin.treeItemRelative.relatives[Relation.CHILD]; // Получаю всех детей для treeItemBegin...
			var key:Boolean = isUID(treeItemEnd.uid, allChildrenUIDs); // Является ли treeItemEnd вообще ребенком для treeItemBegin
			
			if (key) return true;
			
			var relation:Relation;
			for (var i:uint = 0; i < _relations.length; i++) {
				relation = _relations[i];
				if ((relation.treeItemBegin == treeItemBegin && relation.treeItemEnd == treeItemEnd) || (relation.treeItemBegin == treeItemEnd && relation.treeItemEnd == treeItemBegin)) {
					return true;
				}
			}
			return false;
		}
		
		/** Интерфейс */
		
		/** Пересчитываем и перерисовываем связи TreeItem */ 
		public function update():void {
			if (_relations == null) { // Инициализация...
				
				_relations = [];
				
				var treeItems:Array = _tree.treeItems;
				var treeItemBegin:TreeItem;
				var relation:Relation;
				var checkedUIDs:Array = [];
				var relatives:Array;
				var targetRelation:Array;
				var uid:uint;
				var check:Boolean;
				
				var i:uint;
				
				for (i = 0; i < treeItems.length; i++) {
					treeItemBegin = treeItems[i];
					
					relatives = treeItemBegin.treeItemRelative.relatives;
					
					// j - тип родственной связи
					for (var j:uint = 0; j < relatives.length; j++) {
						targetRelation = relatives[j];
						
						for (var k:uint = 0; k < targetRelation.length; k++) {
							
							uid = targetRelation[k];
							
							var treeItemEnd:TreeItem = _tree.getTreeItemByUID(uid);
							
							check = isRelation(treeItemBegin, treeItemEnd);
							
							if (!check) { // Если этот UID уже проверили - не нужно устанавливать связь...

								relation = new Relation(
									this,
									treeItemBegin,
									treeItemEnd,
									new Unions(_tree.relationController, treeItemBegin)
								);
								
								_relations.push(relation);
							}
						}
					}
				}
			}
			
			for (i = 0; i < _relations.length; i++) Relation(_relations[i]).init();
			
			reDraw();
		}
	}
}