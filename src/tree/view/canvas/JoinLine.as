package tree.view.canvas {
	import com.gskinner.geom.ColorMatrix;

	import flash.display.DisplayObject;
	import flash.filters.GlowFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Point;

	import tree.common.Config;

	import tree.model.Join;
	import tree.model.JoinType;
	import tree.model.lines.LineMatrixCollection;
	import tree.model.Node;

	public class JoinLine extends LineBase{

		private var _data:Join;
		private var collection:INodeViewCollection

		protected var lines:Array = [];
		protected var linesLength:int = 1;

		private var drawIcon:Boolean = false;
		private var icon:DisplayObject;
		private var lineModelCollection:LineMatrixCollection;
		private var lineMask:int;
		private var _highlighted:Boolean = false;

		private var animationHash:String;// hash ранее построенной геометрии линии


		public function JoinLine(collection:INodeViewCollection) {
			this.collection = collection;
			cacheAsBitmap = true;
		}

		override public function clear():void {
			super.clear();
			collection = null;
			if(_data){
				_data.visible = false;
				_data = null;
			}
		}

		public function get data():Join {
			return _data;
		}

		public function set data(value:Join):void {
			_data = value;
			drawIcon = _data.type.superType == JoinType.SUPER_TYPE_MARRY;
			if(!lineModelCollection)
				lineModelCollection = Config.inject(LineMatrixCollection);
			value.visible = true;
		}

		override public function draw():void {
			var newHash:String = _progress + ':' + lines.join(',') + ':' + shiftX + ':' + shiftY;
			if(animationHash != newHash){
				drawLine(lines, linesLength * _progress);
				animationHash = newHash;
			}
		}


		override public function hide(animated:Boolean = true):void {
			super.hide(animated);
			removeFromLineMatrix();
		}

		override protected function configurateLine():void {
			var color:int
			var thickness:int = 1;

			var superType:String = _data.type.superType;
			if(superType == JoinType.SUPER_TYPE_BREED
					|| superType == JoinType.SUPER_TYPE_PARENT
					|| superType == JoinType.SUPER_TYPE_MARRY ){
				thickness = 2;
				//color = 0xFFFFFF * Math.random()//0xB2D350;
				color = 0xB2D350;
			}else if(superType == JoinType.SUPER_TYPE_BRO) {
				color = 0x5FC5F5;
			}else{
				color = 0xAAAAAA;
			}
			dashed = superType == JoinType.SUPER_TYPE_EX_MARRY;

			graphics.lineStyle(thickness, color);
		}

		override protected function refreshLines():void {
			removeFromLineMatrix();

			// построить линию n1 -> n2
			var n1:NodeIcon = collection.getNodeIcon(_data.from.uid);
			var n2:NodeIcon = collection.getNodeIcon(_data.uid);
			var p1:Point;
			var p2:Point;
			if(!this.fromStart){
				var tmpN:NodeIcon = n1;
				n1 = n2;
				n2 = tmpN;
			}

			var node1:Node = n1.data.node;
			var node2:Node = n2.data.node;
			lineMask = 0;

			var joinSuperType:String = _data.type.superType;
			if(joinSuperType == JoinType.SUPER_TYPE_MARRY){
				p1 = node1.person.male ? n1.husbandPoint() : n1.wifePoint();
				p2 = node2.person.male ? n2.husbandPoint() : n2.wifePoint();
				addToLines(p1);
				p1.x = (p1.x + p2.x) * 0.5 + shiftX;
				addToLines(p1);
				addToLines(p2);
			}else if(joinSuperType == JoinType.SUPER_TYPE_PARENT || joinSuperType == JoinType.SUPER_TYPE_BREED){
				var p2IsParent:Boolean = (int(this.fromStart) ^ int(joinSuperType == JoinType.SUPER_TYPE_PARENT)) == 0;

				if(p2IsParent){
					p1 = n1.breedPoint();
					p2 = n2.parentPoint(node1);

					addToLines(p1);
					p1.y += -Config.DESCENDING_INT * Canvas.JOIN_BREED_STICK;
					addToLines(p1);
					p1.x = p2.x;
					addToLines(p1);
					addToLines(p2);
				}else{
					p1 = n1.parentPoint(node2);
					p2 = n2.breedPoint();

					addToLines(p1);
					p1.y = p2.y - Config.DESCENDING_INT * Canvas.JOIN_BREED_STICK;
					addToLines(p1);
					p1.x = p2.x;
					addToLines(p1);
					addToLines(p2);
				}
			}else if(joinSuperType == JoinType.SUPER_TYPE_BRO){
				p1 = n1.broPoint();
				p2 = n2.broPoint();
				addToLines(p1);
				p1.y += -Config.DESCENDING_INT * Canvas.JOIN_STICK;
				addToLines(p1);
				p1.x = p2.x;
				addToLines(p1);
				addToLines(p2);
				lineMask = 1
			}else if(joinSuperType == JoinType.SUPER_TYPE_EX_MARRY){
				p1 = n1.exMarryPoint();
				p2 = n2.exMarryPoint();
				addToLines(p1);
				p1.y += -Config.DESCENDING_INT * Canvas.JOIN_STICK;
				addToLines(p1);
				p1.x = p2.x;
				addToLines(p1);
				addToLines(p2);
				lineMask = 2;
			}else
				throw new Error('Undefined Join type: ' + joinSuperType)

			// вычислить смещение, если в этом есть необходимость
			var shift:Point = lineModelCollection.align(lines, _data, lineMask)
			shiftX = shift.x;
			shiftY = shift.y;
		}

		private function addToLines(p:Point):void{
			var x:int = p.x;
			var y:int = p.y;
			var l:int = lines.length;
			if(l)
				linesLength += Math.sqrt(Math.pow(x - lines[l - 2], 2) + Math.pow(y - lines[l - 1], 2));
			lines.push(x);
			lines.push(y);

		}

		override public function toString():String{
			return _data + '';
		}

		override protected function drawLine(line:Array, length:int):void {
			if(drawIcon){
				var x1:int = line[0];
				var x2:int = line[4];
				var y:int = line[1];
				var iconX:int = line[2];
				const iconHalfSize:int = 6.5;

				graphics.clear();
				configurateLine();
				var firstSegment:int = Math.abs(x1 - iconX);
				if(length > firstSegment + iconHalfSize){
					// два участка
					graphics.moveTo(x1, y);
					graphics.lineTo(x1 + (x2 > x1 ? 1 : -1) * (firstSegment - iconHalfSize), y);
					length -= firstSegment + shiftX;

					x2 = x1 + (x2 > x1 ? 1 : -1) * (firstSegment + iconHalfSize)
					graphics.moveTo(x2, y);
					graphics.lineTo(x2 + (x2 > x1 ? 1 : -1) * length, y);
				}else{
					// один участок
					length = Math.min(length, firstSegment - iconHalfSize)
					x2 = x2 > x1 ? x1 + length : x1 - length;
					graphics.moveTo(x1, y);
					graphics.lineTo(x2, y);
				}

				if((linesLength / length) > 0.5){
					// иконка должна быть видна
					if(icon == null || !icon.visible){
						if(!icon){
							icon = Config.loader.createMc('assets.HartLineIcon');
							addChild(icon);
						}
						icon.visible = true;
					}
					icon.x = iconX;
					icon.y = y;
					lineModelCollection.addIcon(data, iconX, y);
				}else{
					// иконка должна быть скрыта
					if(icon && icon.visible)
						icon.visible = false;
					lineModelCollection.removeIcon(data);
				}
			}else
				super.drawLine(line, length);
		}

		public function setShift(shiftX:int, shiftY:int = 0):void{
			this.shiftX = shiftX;
			this.shiftY = shiftY;
			show(false);
		}

		private function removeFromLineMatrix():void{
			if(lines.length){
				lineModelCollection.utilize(lines, _data, lineMask);
				lines = [];
				linesLength = 0;
			}

		}

		public function set highlighted(value:Boolean):void {
			if(_highlighted != value){
				_highlighted = value;
				var colorTransform:ColorTransform = new ColorTransform();
				if(value) colorTransform.color = 0x51BBEC;
				this.transform.colorTransform = colorTransform;
				filters = value ? [new GlowFilter(0x51BBEC, 1, 4, 4)] : []
			}
		}

		public function get highlighted():Boolean {
			return _highlighted;
		}
	}
}
