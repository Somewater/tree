package tree.view.canvas {
	import flash.geom.Point;

	import tree.common.Config;

	import tree.model.Join;
	import tree.model.JoinType;
	import tree.model.Node;

	public class JoinLine extends LineBase{

		private var _data:Join;
		private var collection:INodeViewCollection

		protected var lines:Array = [];
		protected var linesLength:int = 1;


		public function JoinLine(collection:INodeViewCollection) {
			this.collection = collection;
		}

		override public function clear():void {
			super.clear();
			collection = null;
		}

		public function get data():Join {
			return _data;
		}

		public function set data(value:Join):void {
			_data = value;
		}

		override public function draw():void {
			drawLine(lines, linesLength * _progress);
		}


		override protected function configurateLine():void {
			var color:int
			var thickness:int = 1;

			var superType:String = _data.type.superType;
			if(superType == JoinType.SUPER_TYPE_BREED
					|| superType == JoinType.SUPER_TYPE_PARENT
					|| superType == JoinType.SUPER_TYPE_MARRY ){
				thickness = 2;
				color = 0xB2D350;
			}else if(superType == JoinType.SUPER_TYPE_BRO) {
				color = 0x5FC5F5;
			}else{
				color = 0xAAAAAA;
			}

			graphics.lineStyle(thickness, color);
		}

		override protected function refreshLines():void {
			lines = [];
			linesLength = 0;

			// построить линию n1 -> n2
			var n1:NodeIcon = collection.getNodeIcon(_data.from.uid);
			var n2:NodeIcon = collection.getNodeIcon(_data.uid);
			var p1:Point;
			var p2:Point;
			var p:Point;
			if(!this.fromStart){
				var tmpN:NodeIcon = n1;
				n1 = n2;
				n2 = tmpN;
			}

			var node1:Node = n1.data.node;
			var node2:Node = n2.data.node;

			var joinSuperType:String = _data.type.superType;
			if(joinSuperType == JoinType.SUPER_TYPE_MARRY){
				p1 = node1.person.male ? n1.husbandPoint : n1.wifePoint;
				p2 = node2.person.male ? n2.husbandPoint : n2.wifePoint;
				addToLines(p1);
				addToLines(p2);
			}else if(joinSuperType == JoinType.SUPER_TYPE_PARENT || joinSuperType == JoinType.SUPER_TYPE_BREED){
				var p2IsParent:Boolean = (int(this.fromStart) ^ int(joinSuperType == JoinType.SUPER_TYPE_PARENT)) == 0;
				if(p2IsParent){
					p1 = n1.breedPoint;
					p2 = n2.parentPoint;

					addToLines(p1);
					p1.y += -Config.DESCENDING_INT * Canvas.JOIN_BREED_STICK;
					addToLines(p1);
					p1.x = p2.x;
					addToLines(p1);
					addToLines(p2);
				}else{
					p1 = n1.parentPoint;
					p2 = n2.breedPoint;

					addToLines(p1);
					p1.y = p2.y - Config.DESCENDING_INT * Canvas.JOIN_BREED_STICK;
					addToLines(p1);
					p1.x = p2.x;
					addToLines(p1);
					addToLines(p2);
				}
			}else if(joinSuperType == JoinType.SUPER_TYPE_BRO){
				p1 = n1.broPoint;
				p2 = n2.broPoint;
				addToLines(p1);
				p1.y += -Config.DESCENDING_INT * Canvas.JOIN_STICK;
				addToLines(p1);
				p1.x = p2.x;
				addToLines(p1);
				addToLines(p2);
			}else if(joinSuperType == JoinType.SUPER_TYPE_EX_MARRY){
				p1 = n1.exMarryPoint;
				p2 = n2.exMarryPoint;
				addToLines(p1);
				p1.y += -Config.DESCENDING_INT * Canvas.JOIN_STICK;
				addToLines(p1);
				p1.x = p2.x;
				addToLines(p1);
				addToLines(p2);
			}else
				throw new Error('Undefined Join type: ' + joinSuperType)
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
	}
}
