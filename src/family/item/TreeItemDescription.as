package family.item {
	
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.text.TextField;
	
	import utils.Utils;
	
	public class TreeItemDescription extends Sprite implements IUse,IDisposable {
		
		public static const TREE_ITEM_DESCRIPTION_INIT_EVENT:String = "TreeItemDescriptionInitEvent";
		
		private var _treeItem:TreeItem;
		private var _name:TextField;
		private var _foto:Sprite = new Sprite();
		
		public function TreeItemDescription(treeItem:TreeItem) {
			_treeItem = treeItem;
		}
		
		private function onLoadFoto(bitmap:Loader):void {
			_foto.addChild(Bitmap(bitmap.content));
			_foto.y = _name.height;
			addChild(_foto);
			
			dispatchEvent(new Event(TREE_ITEM_DESCRIPTION_INIT_EVENT));
		}
		
		/** Интерфейс */
		
		public function init():void {
			var uid:uint = _treeItem.treeItemInfo.xml.@uid;
			Utils.loadDisplayObject(Constants.TREE_FOTO + uid + Constants.JPG_EXP, onLoadFoto);
			
			var name:String = _treeItem.treeItemInfo.xml.@name;
			_name = Utils.createSizeTextField(_treeItem.treeItemInfo.nameTF, _treeItem.back.width);
			_name.text = name;
			
			addChild(_name);
		}
		
		public function update():void {
			
		}
		
		public function dispose():void {
			
		}
	}
}