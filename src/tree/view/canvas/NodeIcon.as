package tree.view.canvas {
	import com.gskinner.motion.GTween;
	import com.gskinner.motion.GTweener;
	import com.somewater.display.Photo;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;

	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;

	import tree.common.Config;
	import tree.common.IClear;
	import tree.model.GenNode;
	import tree.model.Generation;

	import tree.model.Node;
	import tree.model.Person;
	import tree.view.canvas.Canvas;

	public class NodeIcon extends Sprite implements IClear{

		protected var _data:GenNode;

		private var skin:Sprite;

		private var photo:Photo;

		public var complete:ISignal;

		public function NodeIcon() {
			skin = Config.loader.createMc('assets.NodeAsset');
			addChild(skin);

			photo = new Photo(Photo.SIZE_MAX | Photo.ORIENTED_CENTER);
			photo.photoMask = skin.getChildByName('photo_mask');

			complete = new Signal(NodeIcon);
		}

		public function set data(value:GenNode):void {
			warn('New node: ' + value.node.person + ", time=" + Config.ticker.getTimer)
			this._data = value;
			refreshData();
			refreshPosition();
		}

		public function get data():GenNode {
			return _data;
		}

		protected function refreshData():void {
			var p:Person = _data.node.person;
			skin.getChildByName('male_back').visible = p.male;
			skin.getChildByName('female_back').visible = !p.male;
			(skin.getChildByName('name_tf') as TextField).text = p.name;
			Config.loader.serverHandler.download(p.photo, onPhotoDownloaded, trace);
		}

		private function onPhotoDownloaded(photo:*):void {
			this.photo.source = photo;
		}

		public function refreshPosition():void {
			var node:Node = this._data.node;
			var generation:Generation = this._data.generation;

			var x:int = node.x * (Canvas.ICON_WIDTH + Canvas.ICON_WIDTH_SPACE);
			var y:int = (generation.y + generation.normalize(node.level)) * (Canvas.ICON_HEIGHT + Canvas.HEIGHT_SPACE);
			GTweener.removeTweens(this);
			GTweener.to(this, 0.4, {'x':x, 'y':y}, {onComplete: dispatchOnComplete });
		}

		private function dispatchOnComplete(g:GTween):void {
			complete.dispatch(this);
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
