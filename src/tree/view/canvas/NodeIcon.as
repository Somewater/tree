package tree.view.canvas {
	import com.gskinner.motion.GTween;
	import com.gskinner.motion.GTweener;
	import com.somewater.display.Photo;

	import flash.display.Bitmap;

	import flash.display.BitmapData;

	import flash.display.DisplayObject;

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
import tree.loader.Lib;
import tree.model.GenNode;
	import tree.model.Generation;
	import tree.model.Join;
	import tree.model.Model;

	import tree.model.Node;
	import tree.model.Person;
	import tree.view.Tweener;
	import tree.view.canvas.Canvas;
	import tree.view.gui.Helper;

	public class NodeIcon extends Sprite implements IClear{

		protected var _data:GenNode;

		private var skin:Sprite;

		private var photo:Photo;

		public var complete:ISignal;

		protected var tmpPoint:Point;

		private var debugTrace:TextField;

		public var click:ISignal;
		public var dblClick:ISignal;
		public var over:ISignal;
		public var out:ISignal;

		public var rollUnrollClick:ISignal;
		private var rollUnrollButton:RollUnrollButton;
		private var rollUnrollButtonSwitched:Boolean = false;

		public var showArrowMenu:ISignal;
		public var hideArrowMenu:ISignal;

		private var maleHighlight:DisplayObject;
		private var femaleHighlight:DisplayObject;

		private var _highlighted:Boolean = false;// рамка (при наведении мышкой)
		private var _selected:Boolean = false;// glow (при выборе в GUI)

		private var arrows:Array = [];

		private var bitmap:Bitmap;
		private var bitmapData:BitmapData;

		public function NodeIcon() {
			skin = Config.loader.createMc('assets.NodeAsset');
			maleHighlight = skin.getChildByName('male_back_hl');
			femaleHighlight = skin.getChildByName('female_back_hl');
			maleHighlight.visible = femaleHighlight.visible = false;
			addChild(skin);

			//bitmap = new Bitmap()
			//addChild(bitmap);

			photo = new Photo(Photo.SIZE_MAX | Photo.ORIENTED_CENTER);
			photo.photoMask = skin.getChildByName('photo_mask');

			complete = new Signal(NodeIcon);
			click = new Signal(NodeIcon);
			dblClick = new Signal(NodeIcon);
			over = new Signal(NodeIcon);
			out = new Signal(NodeIcon);

			tmpPoint = new Point();

			CONFIG::debug{
				debugTrace = new TextField();
				debugTrace.wordWrap = debugTrace.multiline = true;
				debugTrace.selectable = false;
				debugTrace.width = Canvas.ICON_WIDTH;
				debugTrace.filters = [new DropShadowFilter(1, 45, 0xFFFFFF, 1, 1, 1, 2)]
				skin.addChild(debugTrace);

				addEventListener(MouseEvent.CLICK, function(ev:Event):void{
					refreshData();
				})
			}

			addEventListener(MouseEvent.CLICK, onClicked);
			addEventListener(MouseEvent.DOUBLE_CLICK, onDblCliced);
			this.doubleClickEnabled = true;
			addEventListener(MouseEvent.MOUSE_OVER, onOver);
			addEventListener(MouseEvent.MOUSE_OUT, onOut);

			rollUnrollClick = new Signal(NodeIcon);
			rollUnrollButton = new RollUnrollButton();
			rollUnrollButton.x = 90;
			rollUnrollButton.y = 0;
			rollUnrollButton.addEventListener(MouseEvent.CLICK, onRollUnrollClicked);
			addChild(rollUnrollButton);

			Helper.stylizeText((skin.getChildByName('name_tf') as TextField));

			showArrowMenu = new Signal(NodeArrow);
			hideArrowMenu = new Signal();

			cacheAsBitmap = true;
			//graphics.beginFill(0xFF0000);
			//graphics.drawRect(0, 0, Canvas.ICON_WIDTH, Canvas.ICON_HEIGHT);
		}

		private function onClicked(event:MouseEvent):void {
			click.dispatch(this);
		}

		private function onDblCliced(event:MouseEvent):void {
			dblClick.dispatch(this);
		}

		private function onOver(event:MouseEvent):void {
			over.dispatch(this);
			if(rollUnrollButtonSwitched && rollUnrollButton.rollState){
				animateRollUnrollButton(true);
			}
		}

		private function onOut(event:MouseEvent):void {
			if(event.relatedObject && this.contains(event.relatedObject))
				return;

			out.dispatch(this);
			if(rollUnrollButtonSwitched && rollUnrollButton.rollState){
				rollUnrollButton.visible = false;
			}
		}

		public function set data(value:GenNode):void {
			warn('New node: ' + value.node.person + ", time=" + Config.ticker.getTimer)
			this._data = value;
			refreshData();
			value.node.visible = true;
			value.node.rollChanged.add(refreshRollUnroll)
			refreshRollUnroll(value.node);
		}

		public function get data():GenNode {
			return _data;
		}

		protected function refreshData():void {
			var p:Person = _data.node.person;
			skin.getChildByName('male_back').visible = p.male;
			skin.getChildByName('female_back').visible = !p.male;
			(skin.getChildByName('name_tf') as TextField).text = p.name;
			if(!p.open)
				this.photo.source = Config.loader.createMc('assets.LockPhoto')
			else if(p.photo)
				Config.loader.serverHandler.download(p.photo, onPhotoDownloaded, trace, null);
			rollUnrollButton.male = _data.node.person.male;
			CONFIG::debug{
				debugTrace.text = p.node.id + "\nx=" + p.node.x + " y=" + p.node.y + "\nv=" + p.node.vector + " vc="
						+ p.node.vectCount + "\nlvl=" + p.node.level + " gen=" + p.node.generation
						+ "\ndist=" + p.node.dist;
			}
			//draw();
		}

		private function onPhotoDownloaded(photo:*):void {
			this.photo.source = photo;
			//draw();
		}

		public function refreshPosition(animated:Boolean = true):void {
			var p:Point = this.position();

			if(animated){
				GTweener.removeTweens(this);
				this.alpha = 1;
				Tweener.to(this, Model.instance.animationTime * 0.5, {'x':p.x, 'y':p.y}, {onComplete: dispatchOnComplete });
			}else{
				this.x = p.x;
				this.y = p.y;
			}
		}

		private function refreshRollUnroll(n:Node):void{
			if(!n.slaves || n.slaves.length == 0)
				hideRollUnroll();
			else
				showRollUnroll();
		}

		private function dispatchOnComplete(g:GTween = null):void {
			complete.dispatch(this);
		}

		public function clear():void {
			if(_data) {
				_data.node.visible = false;
				_data.node.rollChanged.remove(refreshRollUnroll);
				_data.changed.remove(refreshPosition);
				_data = null;
			}
			photo.clear();
			removeEventListener(MouseEvent.CLICK, onClicked);
			removeEventListener(MouseEvent.DOUBLE_CLICK, onDblCliced);
			removeEventListener(MouseEvent.MOUSE_OVER, onOver);
			removeEventListener(MouseEvent.MOUSE_OUT, onOut);
			rollUnrollButton.clear();
			rollUnrollButton.removeEventListener(MouseEvent.CLICK, onRollUnrollClicked);
			click.removeAll();
			dblClick.removeAll()
			complete.removeAll();
			rollUnrollClick.removeAll()
			over.removeAll();
			out.removeAll();
			showArrowMenu.removeAll();
			hideArrowMenu.removeAll();
			GTweener.removeTweens(this);
		}

		public function hide(animated:Boolean = true):void {
			if(animated)
				Tweener.to(this, Model.instance.animationTime * 0.3, {"alpha":0}, {onComplete: dispatchOnComplete })
			else
				alpha = 0;
		}

		public function show(animated:Boolean = true):void {
			if(animated)
				Tweener.to(this, Model.instance.animationTime * 0.3, {"alpha":1}, {onComplete: dispatchOnComplete })
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
			tmpPoint.y += Model.instance.descending ? 0 : Canvas.ICON_HEIGHT;
			return tmpPoint;
		}

		public function parentPoint(forBreed:Node):Point{
			position();
			if(fullParent(forBreed))
			{
				var halfSpase:int = (Canvas.ICON_WIDTH_SPACE * 2 - Canvas.ICON_WIDTH) * 0.5;
				tmpPoint.x += (_data.node.person.male ? halfSpase + Canvas.ICON_WIDTH: -halfSpase);
				tmpPoint.y += Canvas.ICON_HEIGHT * 0.5 + (Model.instance.descending ? 6.5 : -6.5 );//  поправка на полуразмер сердечка
			}else{
				tmpPoint.x += Canvas.ICON_WIDTH * 0.5;
				tmpPoint.y += Model.instance.descending ? Canvas.ICON_HEIGHT : 0;
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
			tmpPoint.y = (generation.getY(Model.instance.descending) + generation.normalize(node.level)) * (Canvas.ICON_HEIGHT + Canvas.HEIGHT_SPACE);
			return tmpPoint;
		}

		public function positionIsDirty():Boolean{
			var p:Point = this.position();
			return int(x) != int(p.x) || int(y) != int(p.y);
		}

		private function onRollUnrollClicked(event:MouseEvent):void {
			rollUnrollClick.dispatch(this);
		}

		public function get highlighted():Boolean {
			return _highlighted;
		}

		public function set highlighted(value:Boolean):void {
			if(_highlighted != value){
				_highlighted = value;
				femaleHighlight.visible = value && _data && _data.node.person.female;
				maleHighlight.visible = value && _data && _data.node.person.male;
				if(value)
					showArrows();
				else
					hideArrows();
			}
		}

		public function hideRollUnroll():void{
			rollUnrollButton.visible = false;
			rollUnrollButtonSwitched = false;
		}

		public function showRollUnroll():void{
			rollUnrollButton.rollState = data.node.slavesUnrolled;
			rollUnrollButtonSwitched = true;
			if(!rollUnrollButton.rollState)
				animateRollUnrollButton(true);
		}

		private function animateRollUnrollButton(show:Boolean):void{
			if(rollUnrollButton.rollState){
				if(!rollUnrollButton.visible){
					rollUnrollButton.visible = true;
					rollUnrollButton.scaleX = rollUnrollButton.scaleY = 0.2;
				}
				rollUnrollButton.alpha = 1;
				Tweener.to(rollUnrollButton, 0.3, {scaleX: 1, scaleY: 1});
			}else{
				rollUnrollButton.visible = true;
				rollUnrollButton.alpha = 0;
				rollUnrollButton.scaleX = rollUnrollButton.scaleY = 1;
				Tweener.to(rollUnrollButton, 0.3, {alpha: 1});
			}
		}

		public function get selected():Boolean {
			return _selected;
		}

		public function set selected(value:Boolean):void {
			if(_selected != value){
				_selected = value;
				if(value){
					var male:Boolean = _data && _data.node.person.male;
					filters = [new GlowFilter(male ? 0x51BBEC : 0xE79BA7, 1, 12, 12)];
				} else {
					filters = [];
				}
			}
		}

		public function deleteArrows():void{
			for each(var a:NodeArrow in arrows)
			{
				a.clear();
				if(a.parent)
					a.parent.removeChild(a);
			}
			arrows = [];
			hideArrowMenu.dispatch();
		}

		private function showArrows():void{
			deleteArrows();
			for (var i:int = 1; i <= 3; i++) {
				if(i == NodeArrow.PARENT && _data.node.person.father && _data.node.person.mother)
					continue;
				var a:NodeArrow = new NodeArrow(this._data.node.person, i);
				addChildAt(a, 0);
				a.showed.add(onArrowShowed);
				a.hided.add(onArrowHided);
				a.over.add(onArrowOver);
				a.out.add(onArrowOut);
				a.show();
				arrows.push(a);
			}
		}

		private function onArrowShowed(a:NodeArrow):void {

		}

		private function onArrowHided(a:NodeArrow):void {
			var idx:int = arrows.indexOf(a);
			if(idx != -1)
				arrows.splice(idx, 1);
			a.clear();
			if(a.parent)
				a.parent.removeChild(a);
		}

		private function hideArrows():void{
			for each(var a:NodeArrow in arrows)
				a.hide();
		}

		private function onArrowOver(a:NodeArrow):void{
			showArrowMenu.dispatch(a);
		}

		private function onArrowOut(a:NodeArrow):void{

		}

		private function draw():void{
			if(bitmapData)
				bitmapData.dispose();
			bitmapData = new BitmapData(Canvas.ICON_WIDTH + 5, Canvas.ICON_HEIGHT + 5, false, 0);
			bitmapData.draw(skin);
			bitmap.bitmapData = bitmapData;
		}
	}
}
