package family.item {
	
	import family.desktop.Desktop;
	import family.item.control.TreeItemDragController;
	import family.level.Level;
	import family.relation.Union;
	import family.tree.Tree;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class TreeItem extends Sprite implements IUse,IDisposable {
		
		public static const TREE_ITEM_INIT_EVENT:String = "TreeItemInitEvent";
		public static const CHANGE_POSITION_EVENT:String = "ChangePositionEvent";
		public static const CHANGE_CONDITION_EVENT:String = "ChangeConditionEvent";
		
		private var _condition:Boolean; // Открыт или закрыт (есть доступ или нет)
		private var _treeItemDescription:TreeItemDescription;
		private var _treeItemInteractive:TreeItemInteractive;
		private var _back:DisplayObject;
		
		private var _level:int = -1;
		private var _oldLevel:int; // Старый номер уровня...
		
		private var _pos:Point; // Позиция айтема в уровне в клетках (ряд, позиция)
		private var _oldPos:Point; // Старая позиция айтема в уровне в клетках (ряд, позиция) - просто для удобства хранения...
		
		private var _uid:int = -1;
		private var _nickname:String;
		private var _tree:Tree;
		private var _treeItemInfo:TreeItemInfo;
		private var _treeItemRelative:TreeItemRelative;
		private var _isInStage:Boolean = false; // На сцене ли, или нет
		private var _container:Sprite = new Sprite();
		private var _containerMask:Sprite = new Sprite();
		private var _backHalfSize:Point;
		private var _treeItemDragController:TreeItemDragController;
		
		public function TreeItem(
			tree:Tree,
			treeItemInfo:TreeItemInfo,
			autoPos:Point = null
		) {
			_tree = tree;
			_treeItemInfo = treeItemInfo;
			
			if (autoPos) { // Позиция выбирается машиной
				_pos = autoPos.clone();
			} else { // Позиция берется из XML
				var p:Array = String(_treeItemInfo.xml.@pos).split(",");
				_pos = new Point(uint(p[0]), uint(p[1]));
			}			
		}
		
		public function get uid():uint { return _uid; }
		public function get nickname():String { return _nickname; }
		public function get treeItemInfo():TreeItemInfo { return _treeItemInfo; }
		public function get isInStage():Boolean { return _isInStage; }
		public function get treeItemRelative():TreeItemRelative { return _treeItemRelative; }
		public function get back():DisplayObject { return _back; }
		public function get tree():Tree { return _tree; }
		public function get backHalfSize():Point { return _backHalfSize; }
		
		public function get level():uint { return _level; }
		public function set level(value:uint):void { _level = value; }
		
		public function get pos():Point { return _pos; }
		public function set pos(value:Point):void {
			_pos = value;
			dispatchEvent(new Event(CHANGE_POSITION_EVENT));
		}
		
		public function get oldPos():Point { return _oldPos; }
		public function set oldPos(value:Point):void { _oldPos = value; }
		
		public function get oldLevel():int { return _oldLevel; }
		public function set oldLevel(value:int):void { _oldLevel = value; }
		
		private function onEddedToStage(e:Event):void {
			_isInStage = true;
		}
		
		private function onRemoveToStage(e:Event):void {
			_isInStage = false;
		}
		
		public function get condition():Boolean { return _condition; }
		
		public function set condition(value:Boolean):void {
			if (_condition == value) return;
			_condition = value;
			
			while(_container.numChildren) _container.removeChildAt(0);
			if (_treeItemInteractive && contains(_treeItemInteractive)) removeChild(_treeItemInteractive);
			
			if (_condition) _back = new ItemOpen();
			else _back = new ItemClose();
			
			_container.addChild(_back);
			
			if (_condition) {
				_container.addChild(_treeItemDescription);
				addChild(_treeItemInteractive);
			}
			
			dispatchEvent(new Event(CHANGE_CONDITION_EVENT));
		}
		
		private function onDoubleClick(e:MouseEvent):void {
			if (_condition) condition = false;
			else condition = true;
			_tree.renew();
		}
		
		// Таскаем...
		private function onDrag(e:MouseEvent):void {
			_tree.makeActive();			
			// Узнаю, может мне нужно таскать еще какие-то TreeItem вместе с this...
			var presentPartnerUnion:Union = _tree.relationController.getPresentPartnerUnion(this);
			_treeItemDragController = new TreeItemDragController(this, presentPartnerUnion);
			_treeItemDragController.addEventListener(TreeItemDragController.STOP_DRAG_EVENT, onStopDrag);
			_treeItemDragController.init();
		}
		
		private function onStopDrag(e:Event):void {
			_treeItemDragController = null;
		}
		
		/** Интерфейс */
		
		public function init():void {
			_uid = treeItemInfo.xml.@uid;
			_nickname = treeItemInfo.xml.@name;
			
			_treeItemRelative = new TreeItemRelative(this);
			
			_back = new ItemClose();
			_containerMask.graphics.beginFill(0);
			var round:uint = Desktop.instance.desktopInfo.levelCellInfo.fill.x;
			_containerMask.graphics.drawRoundRect(0, 0, _back.width, _back.height, round, round); 
			_containerMask.graphics.endFill();
			
			_treeItemDescription = new TreeItemDescription(this);
			_treeItemDescription.init();
			
			_treeItemInteractive = new TreeItemInteractive(this);
			_treeItemInteractive.init();
			
			_treeItemInteractive.addEventListener(MouseEvent.MOUSE_DOWN, onDrag);
			
			_container.mask = _containerMask;
			
			addChild(_container);
			addChild(_containerMask);
			
			// Чтобы не считать постоянно...
			_backHalfSize = new Point(_back.width * .5, _back.height * .5);
			
			addEventListener(Event.ADDED_TO_STAGE, onEddedToStage);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemoveToStage);
			
			_container.doubleClickEnabled = true;
			_container.addEventListener(MouseEvent.DOUBLE_CLICK, onDoubleClick);
			
			_containerMask.mouseChildren = _containerMask.mouseChildren = false;
			_container.mouseChildren = false;
			
			_container.addEventListener(MouseEvent.MOUSE_DOWN, onDrag);
			
			// Устанавливаем исходное состояние TreeItem open/close...
			var con:Boolean = Boolean(uint(_treeItemInfo.xml.@open));
			if (con) {
				_condition = false;
				condition = true;
			} else {
				_condition = true;
				condition = false;
			}
			
			dispatchEvent(new Event(TREE_ITEM_INIT_EVENT));
		}
		
		public function update():void {
			
		}
		
		public function dispose():void {
			removeEventListener(Event.ADDED_TO_STAGE, onEddedToStage);
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemoveToStage);
			_container.removeEventListener(MouseEvent.DOUBLE_CLICK, onDoubleClick);
			_treeItemInteractive.removeEventListener(MouseEvent.MOUSE_DOWN, onDrag);
			_container.removeEventListener(MouseEvent.MOUSE_DOWN, onDrag);
		}
	}
}