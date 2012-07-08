package tree.view.canvas {
	import tree.model.Join;
	import tree.model.JoinType;
	import tree.model.Node;

	public class JoinLine extends LineBase{

		private var _data:Join;
		private var collection:INodeViewCollection


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
			var n1:NodeIcon = collection.getNodeIcon(_data.from.uid);
			var n2:NodeIcon = collection.getNodeIcon(_data.uid);
			if(!this.fromStart){
				var tmpN:NodeIcon = n1;
				n1 = n2;
				n2 = tmpN;
			}

			var line:Array = [];
			var length:int = 0;

			length += Math.pow(n1.x - n2.x, 2) + Math.pow(n1.y - n2.y, 2);
			line.push(n1.x);
			line.push(n1.y);
			line.push(n2.x);
			line.push(n2.y);

			drawLine(line, length * _progress);
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
	}
}
