package family.relation.control {
	
	import family.tree.Tree;
	import family.item.TreeItem;
	import family.relation.Relation;
	import family.relation.Union;
	
	/** Класс который пересчитывает и контролирует типы связей между TreeItems */
	
	public class RelationController {
		
		private var _tree:Tree;
		
		private var _parentUnions:Array = []; // Родительские связи
		private var _presentPartnerUnions:Array = []; // Жесткие брачные связи
		private var _pastPartnerUnions:Array = []; // Слабые брачные связи
		private var _ownSiblingUnions:Array = []; // Жесткие связи братьев и сестер
		private var _siblingUnions:Array = []; // Слабые связи братьев и сестер
		
		public function RelationController(tree:Tree) {
			_tree = tree;
		}
		
		/** Распеределяем родственные связи между родственниками... */
		public function distribute():void {
			
			var treeItem:TreeItem;
			var parents:Array;
			var relators:Array;
			var uid:uint;
			var union:Union;
			var parent:TreeItem;
			
			var i:uint;
			var j:uint;
			
			for (i = 0; i < _tree.treeItems.length; i++) {
				treeItem = _tree.treeItems[i];
				
				// Устанавливаю всех родителей данного родственника...
				parents = treeItem.treeItemRelative.relatives[Relation.PARENT];
				
				for (j = 0; j < parents.length; j++) {
					uid = parents[j];
					union = isParentUnion(uid);
					
					if (!union) {
						parent = _tree.getTreeItemByUID(uid); // Вытаскиваем родителя...
						union = new Union(parent); // Создаем родителя...
						_parentUnions.push(union);
					}
					
					// Добавляем родителю его ребенка...
					union.add(treeItem);
				}
				
				// Устанавливаю всех текущих партнеров (муж/жена) - жесткая связь - Union...
				relators = treeItem.treeItemRelative.relatives[Relation.PRESENT_PARTNER];
				
				if (relators.length) {
					union = new Union(treeItem, new Heart());
					for (j = 0; j < relators.length; j++) {
						uid = relators[j];
						union.add(_tree.getTreeItemByUID(uid));
					}
					_presentPartnerUnions.push(union);
				}
				
				// Устанавливаю всех текущих партнеров (муж/жена) - слабая связь - Union...
				relators = treeItem.treeItemRelative.relatives[Relation.PAST_PARTNER];
				
				if (relators.length) {
					union = new Union(treeItem);
					for (j = 0; j < relators.length; j++) {
						uid = relators[j];
						union.add(_tree.getTreeItemByUID(uid));
					}
					_pastPartnerUnions.push(union);
				}
				
				// Устанавливаю всех текущих родных братьев/сестер - жесткие связи - Union...
				relators = treeItem.treeItemRelative.relatives[Relation.OWN_SIBLING];
				
				if (relators.length) {
					union = new Union(treeItem);
					for (j = 0; j < relators.length; j++) {
						uid = relators[j];
						union.add(_tree.getTreeItemByUID(uid));
					}
					_ownSiblingUnions.push(union);
				}
				
				// Устанавливаю всех текущих братьев/сестер - слабые связи - Union...
				relators = treeItem.treeItemRelative.relatives[Relation.SIBLING];
				
				if (relators.length) {
					union = new Union(treeItem);
					for (j = 0; j < relators.length; j++) {
						uid = relators[j];
						union.add(_tree.getTreeItemByUID(uid));
					}
					_siblingUnions.push(union);
				}
			}
		}
		
		
		
		
		
		
		/** Получить жесткую связь (реальные муж/жена, но не бывшие)... */
		public function getPresentPartnerUnion(treeItem:TreeItem):Union {
			var union:Union;		
			for (var i:uint = 0; i < _presentPartnerUnions.length; i++) {
				union = _presentPartnerUnions[i];
				if (union.parent.uid == treeItem.uid) return union;
			}
			return null;
		}
		
		/** Получить посредственную связь (бывшие муж/жена)... */
		public function getPastPartnerUnion(treeItem:TreeItem):Union {
			var union:Union;
			for (var i:uint = 0; i < _pastPartnerUnions.length; i++) {
				union = _pastPartnerUnions[i];
				if (union.parent.uid == treeItem.uid) return union;
			}
			return null;
		}
		
		/** Получить родительскую связь... */
		public function getParentUnion(treeItem:TreeItem):Union {
			return isParents(treeItem.treeItemRelative.relatives[Relation.PARENT])[0];
		}
		
		/** Получить родную братскую связь... */
		public function getOwnSiblingUnion(treeItem:TreeItem):Union {
			var union:Union;
			for (var i:uint = 0; i < _ownSiblingUnions.length; i++) {
				union = _ownSiblingUnions[i];
				if (union.parent.uid == treeItem.uid) return union;
			}
			return null;
		}
		
		/** Получить посредственную братскую связь... */
		public function getSiblingUnion(treeItem:TreeItem):Union {
			var union:Union;
			for (var i:uint = 0; i < _siblingUnions.length; i++) {
				union = _siblingUnions[i];
				if (union.parent.uid == treeItem.uid) return union;
			}
			return null;
		}
		
		

		
		
		/** Получить родителя по UID его ребенка */
		private function isParentUnion(uid:uint):Union {
			var parent:Union;
			for (var i:uint = 0; i < _parentUnions.length; i++) {
				parent = _parentUnions[i];
				if (parent.parent.uid == uid) return parent;
			}
			return null;
		}
		
		private function isParents(uids:Array):Array {
			var arr:Array = [];
			var parent:Union;
			for (var i:uint = 0; i < uids.length; i++) {
				parent = isParentUnion(uids[i]);
				if (parent) arr.push(parent);
			}
			return arr;
		}			
	}
}