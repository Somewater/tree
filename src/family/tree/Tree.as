package family.tree {
	
	import events.tree.ChangeTreeRelateDrawTypeEvent;
	
	import family.item.TreeItem;
	import family.item.TreeItemInfo;
	import family.item.control.TreeItemAutoPositionController;
	import family.item.control.TreeItemPositionController;
	import family.level.Level;
	import family.level.LevelCell;
	import family.level.LevelCounter;
	import family.relation.Relations;
	import family.relation.control.RelationController;
	import family.tree.control.TreeController;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	
	import layers.control.LayerController;
	
	import menu.SortSetter;
	
	public class Tree extends Sprite implements IUse {
		
		public static const TREE_INIT_EVENT:String = "TreeInitEvent";
		public static const TREE_AUTO_CREATE_ERROR_EVENT:String = "TreeAutoCreateErrorEvent";
		
		private var _uid:int = -1; // Уникальный номер дерева
		private var _level:int = -1; // Вертикальный уровень, относительно которого строится дерево
		
		private var _treeInfo:TreeInfo;
		private var _treeItems:Array = [];
		
		private var _periodCell:LevelCell; // Если это не null, то рисуем дерево в автоматическом режиме относительно этой клетки-осчета
		private var _treeItemAutoPositionController:TreeItemAutoPositionController; // Поиск и контроль позиций TreeItems при авторасстановки
		
		private var _levelCounter:LevelCounter; // Пересчет уровней для каждого TreeItem
		private var _treeItemPositionController:TreeItemPositionController; // Контроль и вывод позиций TreeItem
		
		private var _treeName:TreeName;
		private var _border:TreeBorder;
		private var _relations:Relations;
		
		private var _total:uint;
		private var _init:uint;
		
		private var _relationController:RelationController;
		
		private static var _oldActive:Tree;		
		private var _active:Boolean = false;
		
		public function get active():Boolean { return _active; }
		public function set active(value:Boolean):void { _active = value; }
		
		public function makeActive():void {
			if (_oldActive && _oldActive != this) {
				_oldActive.active = false;
				_oldActive.border.update();
			}
			_active = true; 
			_oldActive = this;
		}
		
		public function Tree(treeInfo:TreeInfo, periodCell:LevelCell = null) {
			_treeInfo = treeInfo;
			_periodCell = periodCell;
			
			_uid = treeInfo.xml.@uid;
			
			if (_periodCell) _level = _periodCell.level.uid; // При автоматическом режиме, берем исходный уровень из periodCell
			else _level = treeInfo.xml.@level; // Берем исходный уровень из XML
			
			_relationController = new RelationController(this);
			_treeItemPositionController = new TreeItemPositionController(this);
			
			_border = new TreeBorder(this);
			_relations = new Relations(this);
			
			addEventListener(ChangeTreeRelateDrawTypeEvent.CHANGE_TREE_RELATE_DRAW_TYPE_EVENT, onChangeRelateDrawType);
			addEventListener(SortSetter.CHANGE_TREE_SORT_TYPE_EVENT, onChangeSortType);
			
			addChild(_border);
			addChild(_relations);
		}
		
		public function get treeInfo():TreeInfo { return _treeInfo; }
		public function get treeItems():Array { return _treeItems; }
		public function get uid():uint { return _uid; }
		public function get level():uint { return _level; }	
		public function get periodCell():LevelCell { return _periodCell; }
		public function get border():TreeBorder { return _border; }
		public function get treeName():TreeName { return _treeName; }
		public function get positionController():TreeItemPositionController { return _treeItemPositionController; }
		public function get relationController():RelationController { return _relationController; }
		public function get relations():Relations { return _relations; }
		
		/** Получить TreeItem по его UID... */
		public function getTreeItemByUID(uid:uint):TreeItem {
			var treeItem:TreeItem;
			for (var i:uint = 0; i < _treeItems.length; i++) {
				treeItem = _treeItems[i];
				if (treeItem.uid == uid) return treeItem;
			}
			throw new Error("Stop! Error! No TreeItem by UID = " + uid + "!");
			return null;
		}
		
		/** Получить все TreeItem по определенному уровню */
		public function getAllTreeItemByLevel(level:uint):Array {
			var arr:Array = [];
			var treeItem:TreeItem;
			for (var i:uint = 0; i < _treeItems.length; i++) {
				treeItem = _treeItems[i];
				if (treeItem.level == level) arr.push(treeItem);
			}
			return arr;			
		}
		
		/** Получить все TreeItems ряда уровня */		
		public function getAllTreeItemsByLevelAndRow(level:Level, k:uint):Array {
			var arr:Array = [];
			var allTreeItemByLevel:Array = getAllTreeItemByLevel(level.uid);
			
			if (!allTreeItemByLevel.length) return null;
			
			var treeItem:TreeItem;
			for (var i:uint = 0; i < allTreeItemByLevel.length; i++) {
				treeItem = allTreeItemByLevel[i];
				if (treeItem.pos.x == k) arr.push(treeItem);
			}
			
			if (!arr.length) arr = null;
			return arr; 
		}
		
		/** Получить количество строк в уровне, в зависисмости от TreeItem с самым большим значением строки... */
		public function getTreeItemMaxRowPosByLevel(level:uint):int {
			var itemsByLevel:Array = getAllTreeItemByLevel(level);
			var maxRow:int = -1;
			var row:uint;
			var treeItem:TreeItem;
			for (var i:uint = 0; i < itemsByLevel.length; i++) {
				treeItem = itemsByLevel[i];
				row = treeItem.pos.x;
				if (row > maxRow) maxRow = row;
			}
			return maxRow;
		}
		
		public function renew():void {
			_relations.update();
			_border.update();
			_treeName.update();
		}
		
		private function onTreeItemInit(e:Event):void {
			e.target.removeEventListener(TreeItem.TREE_ITEM_INIT_EVENT, onTreeItemInit);
			_init++;
			if (_init == _total) {
				
				_levelCounter = new LevelCounter(this);
				_levelCounter.update();
				_relationController.distribute(); // Назначить всем детям своих родителей...
				
				LayerController.instance.addToTreeLayer(_treeName);
				
				// Здесь необходимо найти места для всех айтемов и союзов айтемов, при авторасстановке
				// Если во время поиска места для айтмов нарвались на чужое пространство, или LevelCell уже там не пуста, то выдаем ошибку и прекращаем поиск
				if (_periodCell) { // Автосортировка
					_treeItemAutoPositionController = new TreeItemAutoPositionController(this);
					_treeItemAutoPositionController.addEventListener(TreeItemAutoPositionController.ERROR_EVENT, onErrorAutoPos);
					_treeItemAutoPositionController.addEventListener(TreeItemAutoPositionController.SUCCESS_EVENT, onSuccessAutoPos);
					_treeItemAutoPositionController.init();
				} else {
					dispatchEvent(new Event(TREE_INIT_EVENT));
				}				
			}
		}
		
		// Ошибка при подборе позиции для айтемов дерева при авторасстановке...
		private function onErrorAutoPos(e:Event):void {
			dispatchEvent(new Event(TREE_AUTO_CREATE_ERROR_EVENT));
		}
		
		// Авторасстановка прошла успешно...
		private function onSuccessAutoPos(e:Event):void {
			_treeItemAutoPositionController.removeEventListener(TreeItemAutoPositionController.ERROR_EVENT, onErrorAutoPos);
			_treeItemAutoPositionController.removeEventListener(TreeItemAutoPositionController.SUCCESS_EVENT, onSuccessAutoPos);
			_treeItemAutoPositionController = null;
			
			dispatchEvent(new Event(TREE_INIT_EVENT));
		}
		
		private function onChangeRelateDrawType(e:ChangeTreeRelateDrawTypeEvent):void {
			_relations.type = e.drawType;
			_border.update();
			_treeName.update();
		}
		
		private function onChangeSortType(e:Event):void {
			
		}
		
		// Обновляем данные о новой позиции TreeItem прямо в XML...
		private function onChangePosition(e:Event):void {
			var treeItem:TreeItem = TreeItem(e.target);
			for each (var r:XML in _treeInfo.xml.elements()) {
				if (Number(r.@uid) == treeItem.uid) {
					r.@["pos"] = treeItem.pos.x + "," + treeItem.pos.y;
				}
			}		
		}
		
		// Обновляем данные о новой кондиции TreeItem прямо в XML...
		private function onChangeCondition(e:Event):void {
			var treeItem:TreeItem = TreeItem(e.target);
			var condition:String;
			for each (var r:XML in _treeInfo.xml.elements()) {
				if (Number(r.@uid) == treeItem.uid) {
					if (treeItem.condition) condition = "1";
					else condition = "0";
					r.@["open"] = condition;
				}
			}		
		}
		
		/** Интерфейс */
		
		public function init():void {
			_treeName = new TreeName(this);
			
			var treeInfo:TreeItemInfo;
			var treeItem:TreeItem;
			for each (var r:XML in _treeInfo.xml.elements()) {
				treeInfo = new TreeItemInfo(r, Constants.TREE_ITEM_NAME_FORMAT);
				
				if (_periodCell) treeItem = new TreeItem(this, treeInfo, _periodCell.pos); // Автосортировка
				else treeItem = new TreeItem(this, treeInfo); // Ручная сортировка
				
				treeItem.addEventListener(TreeItem.CHANGE_POSITION_EVENT, onChangePosition);
				treeItem.addEventListener(TreeItem.CHANGE_CONDITION_EVENT, onChangeCondition);
				_treeItems.push(treeItem);
			}
			// Инициализация айтемов дерева...
			_total = _treeItems.length;
			for (var i:uint = 0; i < _treeItems.length; i++) {
				treeItem = _treeItems[i];
				treeItem.addEventListener(TreeItem.TREE_ITEM_INIT_EVENT, onTreeItemInit);
				addChild(treeItem);
				treeItem.init();
			}
		}
		
		public function update():void {
			_treeItemPositionController.update();
			renew();
		}
		
		public function dispose():void {
			while(numChildren) removeChildAt(0);
			
			TreeController.deleteTreeItemsFromTheresLevelCells(this); // Удаляем всю инфу в клетках об айтемах этого дерева...
			
			LayerController.instance.removeFromTreeLayer(_treeName);
			_treeName.dispose();
			
			_border.dispose();
			
			if (_treeItemAutoPositionController) {
				_treeItemAutoPositionController.removeEventListener(TreeItemAutoPositionController.ERROR_EVENT, onErrorAutoPos);
				_treeItemAutoPositionController.removeEventListener(TreeItemAutoPositionController.SUCCESS_EVENT, onSuccessAutoPos);
				_treeItemAutoPositionController.dispose();
			}
						
			var treeItem:TreeItem;			
			for (var i:uint = 0; i < _treeItems.length; i++) {
				treeItem = _treeItems[i];
				treeItem.removeEventListener(TreeItem.CHANGE_POSITION_EVENT, onChangePosition);
				treeItem.removeEventListener(TreeItem.CHANGE_CONDITION_EVENT, onChangeCondition);
				treeItem.dispose();
			}
			removeEventListener(ChangeTreeRelateDrawTypeEvent.CHANGE_TREE_RELATE_DRAW_TYPE_EVENT, onChangeRelateDrawType);
			
			_levelCounter = null;
			_relationController = null;
			_treeItemPositionController = null;
			_treeName = null;
			_periodCell = null;
		}
	}
}