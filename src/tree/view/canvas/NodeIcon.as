package tree.view.canvas {
	import com.gskinner.motion.GTween;
	import com.gskinner.motion.GTweener;
	import com.somewater.display.Photo;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;

	import tree.common.Config;
	import tree.common.IClear;

	import tree.model.Node;
	import tree.model.Person;
	import tree.view.canvas.Canvas;

	public class NodeIcon extends Sprite implements IClear{

		protected var _data:Node;

		private var skin:Sprite;

		private var photo:Photo;

		public function NodeIcon() {
			skin = Config.loader.createMc('assets.NodeAsset');
			addChild(skin);

			photo = new Photo(Photo.SIZE_MAX | Photo.ORIENTED_CENTER);
			photo.photoMask = skin.getChildByName('photo_mask');
		}

		public function set data(value:Node):void {
			this._data = value;
			_data.changed.add(refreshPosition);
			refreshData();
			refreshPosition(_data);
		}

		public function get data():Node {
			return _data;
		}

		protected function refreshData():void {
			var p:Person = _data.person;
			skin.getChildByName('male_back').visible = p.male;
			skin.getChildByName('female_back').visible = !p.male;
			(skin.getChildByName('name_tf') as TextField).text = p.name;
			Config.loader.serverHandler.download(p.photo, onPhotoDownloaded, trace);
		}

		private function onPhotoDownloaded(photo:*):void {
			this.photo.source = photo;
		}

		private var already:Boolean = false;
		private function refreshPosition(n:Node):void {
			var x:int = n.x * (Canvas.ICON_WIDTH + Canvas.ICON_WIDTH_SPACE);
			var y:int = n.y * (Canvas.ICON_HEIGHT + Canvas.HEIGHT_SPACE);
			if(already)
				throw new Error('sdf')
			already = true;
			GTweener.to(this, 0.8, {'x':x, 'y':y}, {onComplete: dispatchOnComplete});
		}

		private function dispatchOnComplete(g:GTween):void {
			dispatchEvent(new Event(Event.COMPLETE))
		}

		public function clear():void {
			if(_data) {
				_data.changed.remove(refreshPosition);
				_data = null;
			}
			photo.clear();
		}
	}
}
