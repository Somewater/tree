package tree.view.canvas {
	import com.gskinner.geom.ColorMatrix;

	import flash.display.DisplayObject;
	import flash.filters.GlowFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Point;

	import tree.common.Config;

	import tree.model.Join;
	import tree.model.JoinType;
	import tree.model.Model;
import tree.model.Person;
import tree.model.lines.LineMatrixCollection;
	import tree.model.Node;

	public class JoinLine extends JoinLineBase{

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

		private var lastAddedLineX:int;
		private var lastAddedLineY:int;

		private var tmpPoint:Point = new Point();


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

		/**
		 * Ноды, с которыми асскоциирована связь юыли удалены (хотя бы одна из них)
		 * (например, в связи с сворачиванием-разворачиванием отредактированного дерева, когда порядок сворачивания-разворачивания не был пересчитан верно)
		 */
		public function nodesIsDead():Boolean{
			return collection.getNodeIcon(_data.from.uid) == null || collection.getNodeIcon(_data.uid) == null;
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

			var node1:Person = n1.data.join.associate;
			var node2:Person = n2.data.join.associate;
			lineMask = 0;
			lastAddedLineX = int.MAX_VALUE;
			lastAddedLineY = int.MAX_VALUE;

			var joinSuperType:String = _data.type.superType;
			if(joinSuperType == JoinType.SUPER_TYPE_MARRY){
				p1 = node1.male ? n1.husbandPoint() : n1.wifePoint();
				p2 = node2.male ? n2.husbandPoint() : n2.wifePoint();
				if(Math.abs(p1.y - p2.y) > Canvas.ICON_HEIGHT * 0.4 /*|| (node1.male && p1.x > p2.x) || (node2.male && p2.x > p1.x)*/){
					addExMarryLine(n1,  n2);
				}else{
					addToLines(p1);
					p1.x = (p1.x + p2.x) * 0.5 + shiftX;
					addToLines(p1);
					p1.x = p2.x;
					addToLines(p1);
				}
			}else if(joinSuperType == JoinType.SUPER_TYPE_PARENT || joinSuperType == JoinType.SUPER_TYPE_BREED){
				var p2IsParent:Boolean = (int(this.fromStart) ^ int(joinSuperType == JoinType.SUPER_TYPE_PARENT)) == 0;

				if(p2IsParent){
					p1 = n1.breedPoint();
					p2 = n2.parentPoint(node1);

					addToLines(p1);
					p1.y += -Model.instance.descendingInt * Canvas.JOIN_BREED_STICK;
					addToLines(p1);
					p1.x = p2.x;
					addToLines(p1);
					addToLines(p2);
				}else{
					p1 = n1.parentPoint(node2);
					p2 = n2.breedPoint();

					addToLines(p1);
					p1.y = p2.y - Model.instance.descendingInt * Canvas.JOIN_BREED_STICK;
					addToLines(p1);
					p1.x = p2.x;
					addToLines(p1);
					addToLines(p2);
				}
			}else if(joinSuperType == JoinType.SUPER_TYPE_BRO){
				p1 = n1.broPoint();
				p2 = n2.broPoint();
				addToLines(p1);
				p1.y += -1 * Canvas.JOIN_STICK;
				addToLines(p1);
				p1.x = p2.x;
				addToLines(p1);
				addToLines(p2);
				lineMask = 1
			}else if(joinSuperType == JoinType.SUPER_TYPE_EX_MARRY){
                addExMarryLine(n1,  n2);
			}else
				throw new Error('Undefined Join type: ' + joinSuperType)

			// вычислить смещение, если в этом есть необходимость
			var shift:Point = lineModelCollection.align(lines, _data, lineMask)
			shiftX = shift.x;
			shiftY = shift.y;
		}

		private function  addExMarryLine(n1:NodeIcon, n2: NodeIcon):void{
			drawIcon = false;
			var p1:Point = n1.exMarryPoint();
			var p2:Point = n2.exMarryPoint();
			addToLines(p1);
			p1.y += -1 * Canvas.JOIN_STICK;
			addToLines(p1);
			p1.x = p2.x;
			addToLines(p1);
			addToLines(p2);
			lineMask = 2;
		}

		private function addToLines(p:Point):void{
			var x:int = p.x;
			var y:int = p.y;
			if(x == lastAddedLineX && y == lastAddedLineY) return
			else{
				lastAddedLineX = x;
				lastAddedLineY = y;
			}
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
			const iconHalfSize:int = 6.5;
			var iconX:int;
			var x1:int;
			var x2:int;
			var y:int;
			const SHIFT_MULTIPLIER:int = 5;

			if(drawIcon){
				x1 = line[0];
				x2 = line[4];
				y = line[1];
				iconX = line[2];

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
					icon.x = iconX + this.shiftX * SHIFT_MULTIPLIER;
					icon.y = y //+ this.shiftY * SHIFT_MULTIPLIER;// KLUDGE
					lineModelCollection.addIcon(data, iconX, y);
				}else{
					// иконка должна быть скрыта
					if(icon && icon.visible)
						icon.visible = false;
					lineModelCollection.removeIcon(data);
				}
			}else{
				if(icon && icon.visible){
					if((line.length == 8) || (line.length == 6)){
						// иконка уже создана, нужно ее отпозиционировать, а также "порвать" среднюю линию посередине
						if(line.length == 6) line.splice(2,2);// вырезаем среднюю (из трех) точку, т.к. она лежит посередине
						var pos:int = line.length == 8 ? 4 : 2;// позиция более дальней точки из двух, внутри которых лежит точка иконки
						x1 = line[pos - 2];
						x2 = line[pos];
						y = line[pos - 1];
						iconX = Math.min(x1, x2) + Math.abs(x1 - x2) * 0.5;
						icon.x = iconX + this.shiftX * SHIFT_MULTIPLIER;
						icon.y = y //+ this.shiftX * SHIFT_MULTIPLIER; // KLUDGE

						// пробелы около сердца
						if(x1 < x2){
							x1 = iconX - iconHalfSize;
							x2 = iconX + iconHalfSize;
						}else{
							x1 = iconX + iconHalfSize;
							x2 = iconX - iconHalfSize;
						}
						line.splice(pos, 0, x1, y, JoinLineBase.MOVE_TO_FLAG, x2, y);

					}
				}
				super.drawLine(line, length);
			}
		}

		public function get iconPosition():Point{
			if(icon && icon.visible){
				tmpPoint.x = icon.x;
				tmpPoint.y = icon.y;
				return tmpPoint;
			}else return null;
		}

		public function setShift(shiftX:int, shiftY:int = 0):void{
			this.shiftX = shiftX;
			this.shiftY = shiftY;
			show(false);
		}

		public function removeFromLineMatrix():void{
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
