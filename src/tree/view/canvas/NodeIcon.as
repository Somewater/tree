package tree.view.canvas {
	import com.gskinner.motion.GTween;
	import com.gskinner.motion.GTweener;
	import com.somewater.display.Photo;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
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

		private var debugTrace:TextField;

		public var click:ISignal;

		public var rollUnrollButton:RollUnrollButton;

		public var deleteClick:ISignal;
		private var deleteButton:RollUnrollButton;

		public function NodeIcon() {
			skin = Config.loader.createMc('assets.NodeAsset');
			addChild(skin);

			photo = new Photo(Photo.SIZE_MAX | Photo.ORIENTED_CENTER);
			photo.photoMask = skin.getChildByName('photo_mask');

			complete = new Signal(NodeIcon);
			click = new Signal(NodeIcon);
			deleteClick = new Signal(NodeIcon);

			tmpPoint = new Point();

			CONFIG::debug{
				debugTrace = new TextField();
				debugTrace.wordWrap = debugTrace.multiline = true;
				debugTrace.selectable = false;
				debugTrace.width = Canvas.ICON_WIDTH;
				debugTrace.filters = [new DropShadowFilter(1, 45, 0xFFFFFF, 1, 1, 1, 2)]
				addChild(debugTrace);

				addEventListener(MouseEvent.CLICK, function(ev:Event):void{
					refreshData();
				})
			}

			addEventListener(MouseEvent.CLICK, onClicked);

			rollUnrollButton = new RollUnrollButton();
			rollUnrollButton.x = 70;
			rollUnrollButton.y = 110;
			addChild(rollUnrollButton);
			rollUnrollButton.visible = false;

			deleteButton = new RollUnrollButton();
			deleteButton.x = 90;
			deleteButton.y = 10;
			addChild(deleteButton);
			deleteButton.addEventListener(MouseEvent.CLICK, onDeletButtonClicked);
			deleteButton.visible = false;
		}

		private function onClicked(event:MouseEvent):void {
			click.dispatch(this);
		}

		public function set data(value:GenNode):void {
			warn('New node: ' + value.node.person + ", time=" + Config.ticker.getTimer)
			this._data = value;
			refreshData();
			value.node.visible = true;
		}

		public function get data():GenNode {
			return _data;
		}

		protected function refreshData():void {
			var p:Person = _data.node.person;
			skin.getChildByName('male_back').visible = p.male;
			skin.getChildByName('female_back').visible = !p.male;
			(skin.getChildByName('name_tf') as TextField).text = p.name;
			if(p.photo)
				Config.loader.serverHandler.download(p.photo, onPhotoDownloaded, trace);
			CONFIG::debug{
				debugTrace.text = "x=" + p.node.x + " y=" + p.node.y + "\nv=" + p.node.vector + " vc="
						+ p.node.vectCount + "\nlvl=" + p.node.level + " gen=" + p.node.generation
						+ "\ndist=" + p.node.dist;
			}
		}

		private function onPhotoDownloaded(photo:*):void {
			this.photo.source = photo;
		}

		public function refreshPosition(animated:Boolean = true):void {
			var p:Point = this.position();

			if(animated){
				GTweener.removeTweens(this);
				this.alpha = 1;
				GTweener.to(this, 0.4, {'x':p.x, 'y':p.y}, {onComplete: dispatchOnComplete });
			}else{
				this.x = p.x;
				this.y = p.y;
			}
		}

		private function dispatchOnComplete(g:GTween = null):void {
			complete.dispatch(this);
		}

		public function clear():void {
			if(_data) {
				_data.node.visible = false;
				_data.changed.remove(refreshPosition);
				_data = null;
			}
			photo.clear();
			removeEventListener(MouseEvent.CLICK, onClicked);
			rollUnrollButton.clear();

			deleteButton.removeEventListener(MouseEvent.CLICK, onDeletButtonClicked);
			deleteClick.removeAll();
			click.removeAll();
			complete.removeAll();
		}

		public function hide(animated:Boolean = true):void {
			if(animated)
				GTweener.to(this, 0.2, {"alpha":0}, {onComplete: dispatchOnComplete })
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
		public function wifePoint():Point{
			position();
			tmpPoint.y += Canvas.ICON_HEIGHT * 0.5;
			return tmpPoint;
		}

		public function husbandPoint():Point{
			position();
			tmpPoint.x += Canvas.ICON_WIDTH;
			tmpPoint.y += Canvas.ICON_HEIGHT * 0.5;
			return tmpPoint;
		}

		public function breedPoint():Point{
			position();
			tmpPoint.x += Canvas.ICON_WIDTH * 0.5;
			return tmpPoint;
		}

		public function parentPoint(forBreed:Node):Point{
			position();
			if(fullParent(forBreed))
			{
				var halfSpase:int = (Canvas.ICON_WIDTH_SPACE * 2 - Canvas.ICON_WIDTH) * 0.5;
				tmpPoint.x += (_data.node.person.male ? halfSpase + Canvas.ICON_WIDTH: -halfSpase);
				tmpPoint.y += Canvas.ICON_HEIGHT * 0.5 + 6.5;//  поправка на полуразмер сердечка
			}else{
				tmpPoint.x += Canvas.ICON_WIDTH * 0.5;
				tmpPoint.y += Canvas.ICON_HEIGHT;
			}
			return tmpPoint;
		}

		public function fullParent(forBreed:Node):Boolean{
			var m:Person = _data.node.marry;
			if(m && m.node.visible)
				return m.breeds.indexOf(forBreed.person) != -1;
			else
				return false;
		}

		public function broPoint():Point{
			position();
			tmpPoint.x += Canvas.ICON_WIDTH * 0.5 - Canvas.JOIN_STICK;
			return tmpPoint;
		}

		public function exMarryPoint():Point{
			position();
			tmpPoint.x += Canvas.ICON_WIDTH * 0.5 + Canvas.JOIN_STICK;
			return tmpPoint;
		}

		public function position():Point {
			var node:Node = this._data.node;
			var generation:Generation = this._data.generation;
			tmpPoint.x = (node.x + node.person.tree.shiftX) * Canvas.ICON_WIDTH_SPACE;
			tmpPoint.y = (generation.y + generation.normalize(node.level)) * (Canvas.ICON_HEIGHT + Canvas.HEIGHT_SPACE);
			return tmpPoint;
		}

		private function onDeletButtonClicked(event:MouseEvent):void {
			deleteClick.dispatch(this);
		}
	}
}
