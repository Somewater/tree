package tree.view.canvas {
	import com.gskinner.motion.GTween;
	import com.gskinner.motion.GTweener;
	import com.somewater.display.Photo;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
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

		protected var tmpPoint:Point;

		public function NodeIcon() {
			skin = Config.loader.createMc('assets.NodeAsset');
			addChild(skin);

			photo = new Photo(Photo.SIZE_MAX | Photo.ORIENTED_CENTER);
			photo.photoMask = skin.getChildByName('photo_mask');

			complete = new Signal(NodeIcon);

			tmpPoint = new Point();
		}

		public function set data(value:GenNode):void {
			warn('New node: ' + value.node.person + ", time=" + Config.ticker.getTimer)
			this._data = value;
			refreshData();
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

		public function refreshPosition(animated:Boolean = true):void {
			var node:Node = this._data.node;
			var generation:Generation = this._data.generation;

			var x:int = node.x * (Canvas.ICON_WIDTH + Canvas.ICON_WIDTH_SPACE);
			var y:int = (generation.y + generation.normalize(node.level)) * (Canvas.ICON_HEIGHT + Canvas.HEIGHT_SPACE);

			if(animated){
				GTweener.removeTweens(this);
				GTweener.to(this, 0.4, {'x':x, 'y':y}, {onComplete: dispatchOnComplete });
			}else{
				this.x = x;
				this.y = y;
			}
		}

		private function dispatchOnComplete(g:GTween = null):void {
			complete.dispatch(this);
		}

		public function clear():void {
			if(_data) {
				_data.changed.remove(refreshPosition);
				_data = null;
			}
			photo.clear();
		}

		public function hide(animated:Boolean = true):void {
			if(animated)
				GTweener.to(this, 0.2, {"alpha":0})
			else
				alpha = 0;
		}

		public function show(animated:Boolean = true):void {
			if(animated)
				GTweener.to(this, 0.2, {"alpha":1}, {onComplete: dispatchOnComplete })
			else
				alpha = 1;
		}

		///////////////////
		//               //
		//  JOIN POINTs  //
		//               //
		///////////////////
		public function get wifePoint():Point{
			tmpPoint.x = this.x;
			tmpPoint.y = this.y + Canvas.ICON_HEIGHT * 0.5;
			return tmpPoint;
		}

		public function get husbandPoint():Point{
			tmpPoint.x = this.x + Canvas.ICON_WIDTH;
			tmpPoint.y = this.y + Canvas.ICON_HEIGHT * 0.5;
			return tmpPoint;
		}

		public function get breedPoint():Point{
			tmpPoint.x = this.x + Canvas.ICON_WIDTH * 0.5;
			tmpPoint.y = this.y;
			return tmpPoint;
		}

		public function get parentPoint():Point{
			if(fullParent())
			{
				tmpPoint.x = this.x + (_data.node.person.male ? Canvas.ICON_WIDTH + Canvas.ICON_WIDTH_SPACE * 0.5: -Canvas.ICON_WIDTH_SPACE * 0.5);
				tmpPoint.y = this.y + Canvas.ICON_HEIGHT * 0.5;
			}else{
				tmpPoint.x = this.x + Canvas.ICON_WIDTH * 0.5;
				tmpPoint.y = this.y + Canvas.ICON_HEIGHT;
			}
			return tmpPoint;
		}

		public function fullParent():Boolean{return _data.node.marry != null;}

		public function get broPoint():Point{
			tmpPoint.x = this.x + Canvas.ICON_WIDTH * 0.5 - Canvas.JOIN_STICK;
			tmpPoint.y = this.y;
			return tmpPoint;
		}

		public function get exMarryPoint():Point{
			tmpPoint.x = this.x + Canvas.ICON_WIDTH * 0.5 + Canvas.JOIN_STICK;
			tmpPoint.y = this.y;
			return tmpPoint;
		}
	}
}
