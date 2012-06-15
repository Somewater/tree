package family.item {
	
	import family.relation.Relation;
	
	import flash.geom.Point;
	
	public class TreeItemRelative {
		
		/** dl относительно родительского узла и типов родственных связей */
		public static const LEVEL:Array = [
			-1, // _parent
			0, // _presentPartner
			0, // _pastPartner/lovers
			1, // _child
			0, // _ownSibling
			0 // _sibling/2-sibling/3-sibling
		];
		
		/** Хранение UID */
		private var _parent:Array = [];
		private var _presentPartner:Array = [];
		private var _pastPartner:Array = [];
		private var _child:Array = [];
		private var _ownSibling:Array = [];
		private var _sibling:Array = [];
		
		private var _relatives:Array = [
			_parent,
			_presentPartner,
			_pastPartner,
			_child,
			_ownSibling,
			_sibling
		];
		
		private var _treeItem:TreeItem;
		
		public function TreeItemRelative(treeItem:TreeItem) {
			_treeItem = treeItem;
			pars();
		}
		
		public function get treeItem():TreeItem { return _treeItem; }
		public function get relatives():Array { return _relatives; }
		
		/** Получить тип родственной связи по TreeItemUID, если этот uid здесь объявлен... */
		public function getRelativeByUID(uid:uint):int {
			var target:Array;
			for (var i:uint = 0; i < _relatives.length; i++) {
				target = _relatives[i];
				for (var j:uint = 0; j < target.length; j++) {
					if (target[j] == uid) return i;
				}
			}
			return -1;
		}
		
		private function pars():void {
			var groupUID:uint;
			var humenUID:uint;
			var targetArr:Array;
			
			for each (var group:XML in _treeItem.treeItemInfo.xml.relatives.elements()) {
				groupUID = group.@type;
				
				// if быстрее чем switch...
				if (groupUID == Relation.PARENT) targetArr = _parent;
				else if (groupUID == Relation.PRESENT_PARTNER) targetArr = _presentPartner;
				else if (groupUID == Relation.PAST_PARTNER) targetArr = _pastPartner;
				else if (groupUID == Relation.CHILD) targetArr = _child;
				else if (groupUID == Relation.OWN_SIBLING) targetArr = _ownSibling;
				else if (groupUID == Relation.SIBLING) targetArr = _sibling;
				else throw new Error("Stop! Error! No RelativeGroup by UID = " + groupUID + "!");
					
				for each (var humen:XML in group.elements()) {
					humenUID = humen.@uid;
					targetArr.push(humenUID);
				}
			}
		}
	}
}