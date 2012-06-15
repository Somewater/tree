package family.relation {
	import family.item.TreeItem;
	import family.relation.control.RelationController;
	
	public class Unions {
		
		public var relationController:RelationController;
		public var treeItem:TreeItem;
		
		public var presentPartnerUnion:Union; // Родной брачный союз
		public var pastPartnerUnion:Union; // Посредственная брачный союз
		public var parentUnion:Union; // Родительский союз
		public var ownSiblingUnion:Union; // Cоюз родных братьев и сестер
		public var siblingUnion:Union; // Cоюз посредственных братьев и сестер
		
		public function Unions(relationController:RelationController, treeItem:TreeItem) {
			this.relationController = relationController;
			this.treeItem = treeItem;
		}
		
		public function init():void {
			presentPartnerUnion = relationController.getPresentPartnerUnion(treeItem);
			pastPartnerUnion = relationController.getPastPartnerUnion(treeItem);
			parentUnion = relationController.getParentUnion(treeItem);
			ownSiblingUnion = relationController.getOwnSiblingUnion(treeItem);
			siblingUnion= relationController.getSiblingUnion(treeItem);
		}
	}
}