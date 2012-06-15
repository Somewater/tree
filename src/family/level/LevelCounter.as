package family.level {
	
	import family.tree.Tree;
	import family.item.TreeItem;
	import family.item.TreeItemRelative;
	
	/** Класс, который проводит перерасчет и назначение уровней айтемам, на основе главного уровня игрока */

	public class LevelCounter implements IUpdate {
		
		private var _tree:Tree;
		private var _checkedUIDs:Array; // Уже проверенные UIDs, чтобы отсеить их при растановки уровня (иначе будет не корректная установка уровня)
		
		public function LevelCounter(tree:Tree) {
			_tree = tree;
		}
		
		// Участвовал ли TreeItem с таким UID в установке уровня...
		private function isChecked(uid:uint):Boolean {
			for (var i:uint = 0; i < _checkedUIDs.length; i++) if (_checkedUIDs[i] == uid) return true;
			return false;
		}
		
		/** Интерфейс */
		
		/** Пересчитать и назначить относительные уровни всем айтемам, в зависимости от уровня игрока */
		public function update():void {
			var treeItem:TreeItem;
			_checkedUIDs = [];
			
			Initializer.instance.log.append("--------------------Устанавливаем уровни для всех айтемов дерева TreeUID = " + _tree.uid + "--------------------");
			
			for (var i:uint = 0; i < _tree.treeItems.length; i++) {
				treeItem = _tree.treeItems[i]; // <---- относительно этого айтема проставляются уровни для детей данного айтема
				
				if (!i) {
					treeItem.level = _tree.level; /** Уровень игрока и самый первый TreeItem */
					_checkedUIDs.push(treeItem.uid); /** Этот UID мы автоматом уже проверили */
					Initializer.instance.log.append("TreeItem [uid = " + treeItem.uid + ", name = " + treeItem.nickname + ", level = " + treeItem.level + "]");
				}
				
				/** Пробегаюсь по каждому виду массива в айтеме (группам его родственников) и узнаю какой уровень проставить родственнику относительно рассматриваемого узла */
				
				var target:Array;
				var relatives:Array = treeItem.treeItemRelative.relatives;
				var uid:uint;
				var ti:TreeItem;
				
				// Пробегаюсь по всем UIDs данного айтема и проставляю для них свои уровни...
				for (var j:uint = 0; j < relatives.length; j++) {
					target = relatives[j];
					
					/** j - это тип родственной связи */
					
					for (var k:uint = 0; k < target.length; k++) {
						uid = target[k];
			
						// Если этот TreeItem с таким UID еще не обрабатывался...
						if (!isChecked(uid)) {
							ti = _tree.getTreeItemByUID(uid);
							
							// Итоговый уровень проверяемого treeItem, относительно его родителя...
							ti.level = treeItem.level + TreeItemRelative.LEVEL[j];
							
							_checkedUIDs.push(uid); // Все, мы проверили данный TreeItem...
							Initializer.instance.log.append("TreeItem [uid = " + ti.uid + ", name = " + ti.nickname + ", level = " + ti.level + "]");
						}
					}
				}
			}
			Initializer.instance.log.append("---------------------------------------------------------------------------------------------------------------------------------");
		}
	}
}