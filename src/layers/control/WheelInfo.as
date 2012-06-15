package layers.control {
	
	import flash.geom.Vector3D;
	
	public class WheelInfo {
		
		public var target:Object;
		
		public var min:Number;
		public var max:Number;
		public var k:Number;
		
		public function WheelInfo(
			target:Object,
			limit:Vector3D
		) {
			this.target = target;
			
			this.min = limit.x;
			this.max = limit.y;
			this.k = limit.z;
		}
	}
}